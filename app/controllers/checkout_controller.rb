class CheckoutController < ApplicationController
  require 'active_merchant'
  require 'rubygems'
  include CustomerSigninSystem
  
  layout 'customer'
  before_filter :require_product_in_cart, :only => [ :shipping_info, :pay, :edit_cart ]
  before_filter :signin_required, :only => [ :shipping_info, :pay, :change_address, :edit_address, :new_address ]
  
  ## Cart Editing Stuft
  
  def add_to_cart
    if params[:mailing_quantity].to_i >  params[:quantity].to_i
      params[:mailing_quantity]=params[:quantity]
    end
    
    product = Product.find(params[:product_id])
    
    cart_product = CartProduct.new( @cart )
    cart_product.product_id = params[:product_id].to_i
    cart_product.quantity = params[:quantity].to_i
    cart_product.soft_options = product.valid_options( params[:product_options] )
    cart_product.mailing_quantity = params[:mailing_quantity].to_i if params[:mailing_quantity]
    
    @cart.add_product cart_product
    session[:return_to_url] = params[:return_to_url]
    redirect_to :action => 'review_cart'
  end
  
  def add_package
    @package = CartPackage.new(@cart, Package.find(params[:package_id]))
    
    for item in @package.package_items do
      if item_params = params[:items][item.id.to_s]
        if param_options = item_params[:options]
          item.product_options.each do | option |
            item.option_values[option] = ProductOptionValue.find(param_options[option.id.to_s]) if param_options[option.id.to_s]
          end
        end
        item.quantity = item_params[:quantity].to_i if item_params[:quantity]
        item.versions = item_params[:versions].to_i if item_params[:versions]
      end
    end 
    
    if package_options = params[:package_options]
      @package.product_options.each do | option |
        @package.option_values[option] = ProductOptionValue.find(package_options[option.id.to_s]) if package_options[option.id.to_s]
      end
    end
    
    @cart.add_package(@package)
    session[:return_to_url] = params[:return_to_url]
    redirect_to :action => 'review_cart'
  end
  
  def remove_product
    if params[:cart_index]
      @cart.remove_product( params[:cart_index].to_i )
    elsif params[:design_index]
      @cart.remove_design_job( params[:design_index].to_i )
    elsif params[:package_index]
      @cart.remove_package(params[:package_index].to_i)
    end
    
    view = params[:view] or 'review_cart'
    
    if request.xhr?
      render :update do | page |
        page["itemsInCart"].update(@cart.length.to_s)
        page.redirect_to review_cart_url
        #page[view].update( render :partial => view )
      end
    else
      redirect_to :action => view
    end
  end
  
  
  def edit_cart
    cart_product = @cart.products[ params[:cart_index].to_i ]
    
    if params[:product_id]
      product = Product.find(params[:product_id])
      cart_product.product_id = product.id
    else
      product = Product.find(cart_product.product_id)
    end
    
    cart_product.custom_name = params[:custom_name] unless params[:custom_name] == "Enter a name for this item"
    cart_product.quantity = params[:quantity].to_i
    cart_product.soft_options = product.valid_options( params[:product_options] )
    cart_product.mailing_quantity = params[:mailing_quantity].to_i
    cart_product.reseller_id = params[:reseller_id]
    cart_product.comments = params[:comments]
    
    cart_product.mail_house = (params[:products][params[:cart_index]][:tax_exempt] == 'mail')
    
    
    if request.xhr?
      render :update do | page |
        page['review_cart'].update(render(:partial => 'review_cart_editable'))
      end
    else
      redirect_to :action => 'review_cart'
    end
  end
  
  def edit_package
    item = @cart.package_items[ params[:edit_item].to_i ]
    
    item_params = params[:items][item.id.to_s]
    if param_options = item_params[:options]
      item.product_options.each do | option |
        item.option_values[option] = ProductOptionValue.find(param_options[option.id.to_s]) if param_options[option.id.to_s]
      end
    end
    item.quantity = item_params[:quantity].to_i if item_params[:quantity]
    item.versions = item_params[:versions].to_i if item_params[:versions]
    item.reseller_id = item_params[:reseller_id]
    item.comments = item_params[:comments]
    item.mail_house = (item_params[:tax_exempt] == 'mail')
    
    if request.xhr?
      render :update do | page |
        page['review_cart'].update(render(:partial => 'review_cart_editable'))
      end
    else
      redirect_to :action => 'review_cart'
    end
  end
  
  ## Checkout Views
  def review_cart
    @page_title = "Rocket Postcards - Review Cart"
    session[:return_to_url] = params[:return_to_url] if params[:return_to_url]
    @show_tax = true if signed_in?
    
    if request.xhr?
      render :update do | page |
        page['review_cart'].update(render(:partial => 'review_cart'))
      end
    else
      render :action => "review_cart_editable"
    end
  end
  
  def shipping_info    
    @page_title = "Rocket Postcards - Checkout"
    @show_tax = true
    @show_shipping = true
    
    # Add Order and Invoice to database. # Modified by SUHAS  - August 06, 2008
    if request.get?  
      add_order_invoice
    end
    
    if request.post?  
      
      if params[ :product ]
        params[ :product ].each do | cart_index, ship_options |
          cart_product = @cart.products[ cart_index.to_i ]
          if ship_options[ :shipping_location ] == "ship"
            cart_product.shipping_method_id = ship_options[ :shipping_method_id ].to_i
            cart_product.shipping_address_id = @current_customer.shipping_address_id unless cart_product.shipping_address_id
          else
            cart_product.shipping_method_id = nil
            cart_product.shipping_address_id = nil
          end
        end
      end
      
      if params[:package]
        params[:package].each do |cart_index, ship_options|
          item = @cart.package_items[cart_index.to_i]
          if ship_options[:shipping_location] == 'ship'
            item.shipping_method_id = ship_options[ :shipping_method_id ].to_i
            item.shipping_address_id = @current_customer.shipping_address_id unless item.shipping_address_id
          else
            item.shipping_method_id = nil
            item.shipping_address_id = nil
          end
        end
      end
      
      @cart.design_jobs.each do | cart_design |
        if cart_design.soft_options[:proof] == "true" and ( cart_design.soft_options[:proof_delivery] == "mail" or cart_design.soft_options[:proof_delivery] == "messenger" or cart_design.soft_options[:proof_delivery] == "overnight" )
          cart_design.shipping_address_id ||= @current_customer.shipping_address_id
          cart_design.shipping_method_id ||= cart_design.soft_options[:proof_delivery]
        end
      end
    end
    
    @cart.products.each{ |cp| cp.get_ups_rates }
    @cart.packages.collect(&:package_items).flatten.each{ |item| 
      
      logger.debug "product: #{item.product.id}"
      logger.debug "boxes: #{item.boxes.to_yaml}"
      item.get_ups_rates }
    
    if request.xhr?
      render :update do | page |
        page['shipping_info'].update(render(:partial => 'shipping_info'))
      end
      return
    end
    
    redirect_to :action => 'pay' if params[ :proceed ] or params['proceed.x']
  end
  
  #Payment Method  For PayflowGateway
  def payment_stuff
    ActiveMerchant::Billing::Base.mode = :test
    creditcard = ActiveMerchant::Billing::CreditCard.new({
      :first_name         => params[:credit_cardholder].to_s.split.first,
      :last_name          => (params[:credit_cardholder].to_s.split[1..-1]).to_a.join(' '),
      :number             =>  params[:credit_number].to_s,
      :month              => params[:credit_month].to_s,
      :year               => params[:credit_year].to_s,
      :verification_value => params[:credit_civ].to_s,
      :type =>params[:credit_type].to_s
    })
    gateway = ActiveMerchant::Billing::PayflowGateway.new(
                                                          :user     => 'nomaddesign',
    :login    => 'nomaddesign',
    :password => 'webadmin77',
    :partner  => 'verisign'
    )
    @response = gateway.authorize(1000, creditcard)
    
  end
  
  
  def pay
    @page_title = "Rocket Postcards - Checkout"
    @show_tax = true
    @show_shipping = true
    if request.post?
      if params[:payment_method]== 'check' && (params[:check_name]=="" || params[:check_number]=="")
        flash[:check_message]="Name and Check field can't be blank"
        redirect_to :action => 'pay'
        
      else
        User.waive_security
        ActiveMerchant::Billing::Base.mode = :test
        
        if params[:payment_method]=='credit'
          payment_hash = {
            :method => params[:payment_method],
            :credit_type => params[:credit_type],
            :card_number => params[:credit_number],
            :expiration => ( params[:credit_month] + params[:credit_year][2,2] ),
            :month => params[:credit_month],
            :year => params[:credit_year],
            :name => params[:credit_cardholder],
            :cvv2 => params[:credit_civ]
          }
                
          payment_stuff()#calling the payment getway only if the mode is credit card
          @result_payment= @response.success?
        else
          # If payment method is 'CHEQUE' - Modified on 'Nov 1, 2008' by SUHAS
          payment_hash = {
            :method => params[:payment_method],
            :check_name => params[:check_name],
            :check_number => params[:check_number]
          }
        end
        invoice = Invoice.new(:customer => @current_customer, :address => @current_customer.billing_address)
        delete_me = []
        @cart.package_items.each do |item|
          item.add_payment(payment_hash.update(:amount => item.total_price))
          item.authorize_payment
          invoice.save
          item.to_orders(invoice).each do |order|
            order.status = Order.statuses[0]
            order.save!
          end
          # delete_me << item.package unless delete_me.include?(item.package)
        end
        i= 1
        
        # Destroy old added orders in this session to avoid repeatation. - Changed by Naveen - March 4, 2009
        @order_s = session[:order_s].join(",")
        @order_del = Order.find(:first, :conditions => ["id IN (?)", @order_s ])
        Invoice.find(@order_del.invoice_id).destroy rescue ''
        Order.destroy_all("id IN (#{@order_s})" )
        # Destroy code ends.        
        
        @cart.products.each do | cart_product |
          cart_product.add_payment(payment_hash.update(:amount => cart_product.total_price))
          cart_product.authorize_payment
          invoice.save
          order = cart_product.to_order(Order.new(:invoice => invoice))
          order.status = Order.statuses[0]
          order.save!
          cart_product.order_id = order.id
          
          if params[:payment_method]== 'credit'
            @payment= CreditPayment.new
            @payment.approved = @response.success?
            @payment.pnref = @response.authorization
            @payment.message = @response.message
            @payment.type =  params[:credit_type].capitalize+'Payment'
            @payment.kind =  params[:payment_method].capitalize+'Payment'
            @payment.name =  params[:credit_cardholder]
            @payment.exp_month =  params[:credit_month]
            @payment.amount = cart_product.total_price
            @payment.exp_year =params[:credit_year]
            @payment.order_id=order.id
            @payment.number = params[:credit_number][-4..-1]
            @payment.save
            # CreditPayment.delete( :conditions => ["order_id =? AND type=VisaPayment",order.id])
            # delete_me << cart_product
          end
        end
        
        @cart.design_jobs.each do | design_job |
          design_job.add_payment(payment_hash.update(:amount => design_job.total_price))
          design_job.authorize_payment
          invoice.save
          design_order = design_job.to_order(DesignOrder.new(:invoice => invoice))
          design_order.save
          #delete_me << design_job
        end
        
# Commented by SUHAS
#        @test = CreditPayment.find( :all,:conditions => ["number =?",4111111111111115])
#        
#        for test in @test
#          test.destroy
#        end
        
        if params[:payment_method]=='credit'
          if @result_payment ==false
            CustomerMail.deliver_order_confirmation( invoice )
            flash[:payment_message]= @response.message
            redirect_to :action => 'pay'
          else
            session[:most_recent_invoice_id] = invoice.id
            CustomerMail.deliver_order_confirmation( invoice )
            #            @cart.design_jobs
            #            @cart.products.delete
            #          
            
            redirect_to :action => 'payment_summary'
            
          end
        elsif
          session[:most_recent_invoice_id] = invoice.id
          CustomerMail.deliver_order_confirmation( invoice )
          #          delete_me <<  @cart.design_jobs
          #          delete_me <<  @cart.products
          #          delete_me << @cart.package_items unless delete_me.include?(@cart.package_items)
          #           delete_me.each{ | thing | @cart.products.delete(thing); @cart.design_jobs.delete(thing); @cart.packages.delete(thing) }
          redirect_to :action => 'payment_summary'
          
        end
      end
    end
  end
  
  def payment_summary
    @cart = session[:cart] = Cart.new   # To clear cart. Added by Suhas, Sept 22, 2008
    if params[:invoice_id] and @invoice = Invoice.find( params[:invoice_id] ) and @invoice.customer == @current_customer
      render
      return
    elsif session[:most_recent_invoice_id] and @invoice = Invoice.find(session[:most_recent_invoice_id]) and @invoice.customer_id == @current_customer.id
      render
      return
    else
      render_text "No valid invoice found."
    end
  end
  
  def printable_invoice
    if params[:invoice_id] and @invoice = Invoice.find( params[:invoice_id] ) and @invoice.customer == @current_customer
      render :layout => false
    elsif session[:most_recent_invoice_id] and @invoice = Invoice.find(session[:most_recent_invoice_id]) and @invoice.customer_id == @current_customer.id
      render :layout => false
    else
      render_text "No valid invoice found."
    end
  end
  
  ### ADDRESS views/actions
  def change_address
    @page_title = "Rocket Postcards - Checkout"
    
    if request.post?
      if params[:ship_to_address]
        if params[:edit_item]
          @cart.products[ params[:edit_item].to_i ].shipping_address_id = params[:ship_to_address].to_i
        elsif params[:edit_design]
          @cart.design_jobs[ params[:edit_design].to_i ].shipping_address_id = params[:ship_to_address].to_i
        end
        redirect_to :action => 'shipping_info'
      end
    end    
  end
  
  def edit_address
    @page_title = "Rocket Postcards - Checkout"
    
    @address = Address.find(params[:address_id])
    
    if request.post? and params[:address]
      @address.label = params[:address][:label]
      @address.first_name = params[:address][:first_name]
      @address.last_name = params[:address][:last_name]
      @address.company = params[:address][:company]
      @address.street_1 = params[:address][:street_1]
      @address.street_2 = params[:address][:street_2]
      @address.city = params[:address][:city]
      @address.zip = params[:address][:zip]
      @address.state = params[:address][:state]
      @address.phone = params[:address][:phone]  
      @address.save
      
      redirect_to :action => 'change_address', :edit_item => params[:edit_item]
    end
  end
  
  def new_address
    if request.post? and params[:new_address]
      address = Address.new
      
      if params[:new_address][:label].empty?
        new_address_number = 1
        @current_customer.addresses.each do | ad |
          if this_label = /Address \d+/.match( ad.label )
            if this_label.to_s.split(" ").last.to_i >= new_address_number
              new_address_number = this_label.to_s.split(" ").last.to_i + 1
            end
          end
        end
        address.label = "Address " + new_address_number.to_s
      end
      address.label = params[:new_address][:label] unless address.label
      
      address.first_name = params[:new_address][:first_name]
      address.last_name = params[:new_address][:last_name]
      address.company = params[:new_address][:company]
      address.street_1 = params[:new_address][:street_1]
      address.street_2 = params[:new_address][:street_2]
      address.city = params[:new_address][:city]
      address.zip = params[:new_address][:zip]
      address.state = params[:new_address][:state]
      address.phone = params[:new_address][:phone]
      address.customer = @current_customer
      address.save
    end
    
    redirect_to :action => 'change_address', :edit_item => params[:edit_item]
  end
  
  ##### DESIGN
  
  def design_start
    if request.post?
      case params[:design_type]
      when "new"
        redirect_to :action => 'design_details'
      when "reorder"
        redirect_to :action => 'design_reorder'
      when "reorder_with_changes"
        redirect_to :action => 'design_reorder_changes'
      end 
    end
  end
  
  def design_reorder
    @cart_design = CartDesign.new( @cart )
    @cart_design.soft_options = params[:design_options]
    @cart_design.job_number = params[:job_number]
    @cart_design.comments = params[:comments]
    @cart_design.for_cart_item = @cart.products[ params[:for_cart_item].to_i ] if params[:for_cart_item]
    @cart_design.for_product_id = params[:for_product_id]
    
    if request.post?
      if params[:job_number].empty?
        flash.now[:error] = "You must provide a Rocket job number."
      elsif params[:job_number] != params[:confirm_job_number]
        flash.now[:error] = "You must confirm the job number."
      elsif DesignOrder.find( :first, :conditions => [ "full_job_number = ?", params[:job_number] ] ).nil?
        flash.now[:error] = "The job number you provided did not match any on record. Make sure you enter it in its entirety. For example, RD1234-1"  
      end
      
      unless flash.now[:error]
        @cart.add_design_job @cart_design
        redirect_to :action => 'review_cart'
      else
        render :action => 'design_reorder_changes' unless @cart_design.soft_options.empty?
      end
    end
  end
  
  def design_reorder_changes
    @cart_design = CartDesign.new(@cart)
  end
  
  def design_details
    @cart_design = CartDesign.new(@cart)
    unless @cart.products.empty?
      @cart_design.for_cart_item = @cart.products.first
    else
      @cart_design.for_product_id = Product.find(:first, :order => 'product_page_id' ).id
    end
    
    if request.post?
      @cart_design.soft_options = params[:design_options]
      @cart_design.custom_name = params[:custom_name]
      @cart_design.copy = params[:copy]
      @cart_design.comments = params[:comments]
      
      if params[:for_cart_item]
        if match = params[:for_cart_item].match(/product_(\d+)/) and cart_index = match.captures.first.to_i
          @cart_design.for_cart_item = @cart.products[cart_index]
        elsif match = params[:for_cart_item].match(/package_item_(\d+)/) and cart_index = match.captures.first.to_i
          @cart_design.for_cart_item = @cart.package_items[cart_index]
        end
      else
        @cart_design.for_product_id = params[:for_product_id].to_i
      end
      
      
      if params[:submit] or params['submit.x']
        @cart.add_design_job @cart_design
        redirect_to :action => 'review_cart'
      elsif request.xhr?
        render :update do | page |
          page['design_details'].update render(:partial => 'design_details')
        end
      end
    end
  end
  
  def edit_design
    cart_design = @cart.design_jobs[ params[ :design_index].to_i ]
    cart_design.soft_options = params[:design_options]
    cart_design.custom_name = params[:custom_name]
    cart_design.copy = params[:copy]
    cart_design.comments = params[:comments]
    
    if params[:for_cart_item]
      if match = params[:for_cart_item].match(/product_(\d+)/) and cart_index = match.captures.first.to_i
        cart_design.for_cart_item = @cart.products[cart_index]
      elsif match = params[:for_cart_item].match(/package_item_(\d+)/) and cart_index = match.captures.first.to_i
        cart_design.for_cart_item = @cart.package_items[cart_index]
      end
    else
      cart_design.for_product_id = params[:for_product_id].to_i
    end
    
    if request.xhr?
      params[:edit_design] = params[:design_index] unless params[:save]    
      render :update do | page |
        page['review_cart'].update(render(:partial => 'review_cart_editable'))
      end
    else
      redirect_to :action => 'review_cart'
    end
  end
  
  def apply_coupon
    @show_shipping = true
    @show_tax = true
    
    if @coupon = Coupon.find_by_code(params[:code])
      winning_products = @cart.apply_coupon_to_products(@coupon)
      winning_package_items = @cart.apply_coupon_to_packages(@coupon)
    end
    
    render :update => true, :layout => false do |page|
      if @coupon and not (winning_products.length + winning_package_items.length).zero?  
        i = 0
        page['coupon_message'].update ''
        winning_package_items.each do |item|
          new_total_html = render(:partial => 'cart_package_totals', :locals => {:item => item})
          page << %Q{ update_item_#{item.cart_index} = #{new_total_html.dump}}
          page << %Q{ setTimeout('new Effect.ScrollTo("cart_package_item_#{item.cart_index}", {offset: -24, queue: "end", afterFinish: function() { $("cart_package_totals_#{item.cart_index}").update(update_item_#{item.cart_index}); }}); new Effect.Highlight("cart_package_totals_#{item.cart_index}", {endcolor: "#ececec", queue: "end"})', #{i * 2000})}
          i+= 1
        end
        
        winning_products.each do |product|
          new_total_html = render(:partial => 'cart_product_totals', :locals => {:cart_product => product})
          page << %Q{ update_product_#{product.cart_index} = #{new_total_html.dump}}
          page << %Q{ setTimeout('new Effect.ScrollTo("cart_product_#{product.cart_index}", {offset: -24, queue: "end", afterFinish: function() { $("cart_product_totals_#{product.cart_index}").update(update_product_#{product.cart_index}) }}); new Effect.Highlight("cart_product_totals_#{product.cart_index}", {endcolor: "#ececec", queue: "end"})', #{i * 2000})}
          i += 1
        end
        
        page << %Q{ cart_total_update = #{render(:partial => 'cart_totals').dump}}
        
        page << %Q{ setTimeout('new Effect.ScrollTo("cart_totals", {offset: -24, queue: "end", afterFinish: function() { $("cart_totals").update(cart_total_update); $("order_total_value").update("#{number_to_currency(@cart.total)}") }});', #{i * 2000})}
        
      elsif @coupon
        page['coupon_message'].update "The coupon code you entered is valid, but it does not apply to any of the products in your cart."
      else
        page['coupon_message'].update "Sorry, '#{params[:code]}' is not a valid coupon code"
      end
    end
  end
  
  def cid
    render :layout => false
    return
  end
  
  ######### ACCOUNT ACTIONS
  
  
  private
  
  
  def validate_address(address_type)
    
    address_symbol = (address_type.to_s + "_address").to_sym
    
    if params[:customer][address_symbol][:first_name].empty?
      flash.now[:error] += "<p>You must provide a <strong>first name</strong> for the <strong>#{address_type}</strong> address.</p>"
    end
    
    if params[:customer][address_symbol][:last_name].empty?
      flash.now[:error] += "<p>You must provide a <strong>last name</strong> for the <strong>#{address_type}</strong> address.</p>"
    end
    
    if params[:customer][address_symbol][:address_1].empty?
      flash.now[:error] += "<p>You must provide a <strong>street address</strong> for the <strong>#{address_type}</strong> address.</p>"
    end
    
    if params[:customer][address_symbol][:city].empty?
      flash.now[:error] += "<p>You must provide a <strong>city</strong> for the <strong>#{address_type}</strong> address.</p>"
    end
    
    if params[:customer][address_symbol][:zip].empty?
      flash.now[:error] += "<p>You must provide a <strong>zip code</strong> for the <strong>#{address_type}</strong> address.</p>"
    end
    
    if params[:customer][address_symbol][:phone].empty?
      flash.now[:error] += "<p>You must provide a <strong>phone number</strong> for the <strong>#{address_type}</strong> address.</p>"
    end
    
  end
  
  def require_product_in_cart
    unless  ( @cart.products.length > 0 or @cart.design_jobs.length > 0 or @cart.packages.length > 0 ) 
      redirect_to( :action => 'review_cart' ) 
      return false
    end
  end
  
  # Added by SUHAS  - August 06, 2008
  def add_order_invoice
    if params[:payment_method]== 'check' && (params[:check_name]=="" || params[:check_number]=="")
      flash[:check_message]="Name and Check field can't be blank"
      redirect_to :action => 'pay'
      
    else
      User.waive_security
      invoice = Invoice.new(:customer => @current_customer, :address => @current_customer.billing_address)
      delete_me = []
      @cart.package_items.each do |item|
        #item.add_payment(payment_hash.update(:amount => item.total_price))
        #item.authorize_payment
        invoice.save
        item.to_orders(invoice).each do |order|
          order.status = Order.statuses[0]
          order.save!
        end
        # delete_me << item.package unless delete_me.include?(item.package)
      end
      i= 1
      
      @order_id = []
      @cart.products.each do | cart_product |
        invoice.save
        order = cart_product.to_order(Order.new(:invoice => invoice))
        order.status = Order.statuses[0]
        order.save!
        @order_id << order.id
        cart_product.order_id = order.id         
      end
      
      # Added by Naveen - as this session variable will be used to removed currently added orders to avoid repeatation of these orders in database. - March 4, 2009
      session[:order_s] = @order_id
      
      @cart.design_jobs.each do | design_job |
        design_job.add_payment(payment_hash.update(:amount => design_job.total_price))
        design_job.authorize_payment
        invoice.save
        design_order = design_job.to_order(DesignOrder.new(:invoice => invoice))
        design_order.save
        #delete_me << design_job
      end
      
#      @test = CreditPayment.find( :all,:conditions => ["number =?",4111111111111115])
#      
#      for test in @test
#        test.destroy
#      end
      
    end
  end
  
  
end
