class AccountController < ApplicationController
  
  include CustomerSigninSystem
  
  before_filter :signin_required, :only => [ :profile ]
  
  layout 'customer'
  
  def confirm_updated
    @current_customer.confirm_updated = true
    @current_customer.save
    respond_to do |wants|
      wants.html { render }
      wants.js  do 
        render :layout => false, :action => 'confirm_updated_modal'
      end
    end
  end
  
  def forgot_password
    if request.post?
      if @customer = Customer.find( :first, :conditions => ["email = ?", params[:email] ] )
        auth_code = Digest::SHA1.hexdigest( @customer.email + @customer.first_name + "nomad" )
        reset_url = url_for :controller => 'account', :action => 'reset_password', :email => @customer.email, :auth_code => auth_code
        CustomerMail.deliver_forgot_password( @customer, reset_url )
        flash[:error] = "<p>An email has been sent to you containing instructions for resetting your password.</p>"
        redirect_to :action => 'signin'
      else
        flash[:error] = "<p>We were unable to find an account with the email address you provided.</p>"
      end
    end
  end
  
  
  def reset_password
    if @customer = Customer.find( :first, :conditions => [ "email = ?", params[:email]]) and params[:auth_code] == Digest::SHA1.hexdigest( @customer.email + @customer.first_name + "nomad" )
      if request.post?
        if params[:password].nil? or params[:password].empty?
          flash.now[:error] = "<p>You must provide a <strong>password</strong> and confirm it.</p>"
        elsif params[:password] != params[:password_confirmation]
          flash.now[:error] = "<p>The <strong>passwords</strong> you provided did not match. Please re-enter them.</p>"
        end
        unless flash.now[:error]
          @customer.password = params[:password] 
          @customer.save
          session[:customer] = @customer.id
          redirect_to :controller => 'checkout', :action => 'review_cart'
        end
      end
    else
      redirect_to :controller => 'products', :action => 'home'
    end
  end
  
  
  def create_account
    @page_title = "Rocket Postcards: Create Account "
    
    if request.post?
      flash.now[:error] = ''
      
      ## Validate email & password
      if params[:customer][:email].empty? or not params[:customer][:email].include?("@") or not params[:customer][:email].include?(".")
        flash.now[:error] += "<p>You must provide a valid <strong>email address</strong>.</p>"
      elsif Customer.find(:first, :conditions => ["email = ?", params[:customer][:email] ] )  
        flash.now[:error] += "<p>We already have an account on record with the email address you provided.</p>"
      end
      
      if params[:customer][:password].empty? 
        flash.now[:error] += "<p>You must provide a <strong>password</strong> and confirm it.</p>"
      elsif not (params[:customer][:password ] == params[:customer][:confirm_password])
        flash.now[:error] += "<p>The <strong>passwords</strong> you provided did not match. Please re-enter them.</p>"
      end
      
      validate_address :billing
      validate_address( :shipping ) unless params[:same_address] == "1"
      
      flash.now[:error] = nil if flash.now[:error].empty?
      
      unless flash[:error]
        
        customer = Customer.new  
        customer.email = params[:customer][:email]
        customer.password = params[:customer][:password]
        customer.first_name = params[:customer][:billing_address][:first_name]
        customer.last_name = params[:customer][:billing_address][:last_name]
        customer.company = params[:customer][:billing_address][:company]
        customer.phone = params[:customer][:billing_address][:phone]
        customer.fax = params[:customer][:billing_address][:fax]
        customer.reseller_id = params[:customer][:reseller_id]
        customer.kind = params[:customer][:kind]
        customer.send_promo = true if params[:customer][:send_promo]
        customer.save
        
        
        billing_address = Address.new
        billing_address.label = "Address 1"
        billing_address.first_name = params[:customer][:billing_address][:first_name]
        billing_address.last_name = params[:customer][:billing_address][:last_name]
        billing_address.company = params[:customer][:billing_address][:company]
        billing_address.street_1 = params[:customer][:billing_address][:address_1]
        billing_address.street_2 = params[:customer][:billing_address][:address_2]
        billing_address.city = params[:customer][:billing_address][:city]
        billing_address.state = params[:customer][:billing_address][:state]
        billing_address.zip = params[:customer][:billing_address][:zip]
        billing_address.phone = params[:customer][:billing_address][:phone]
        billing_address.customer_id = customer.id
        billing_address.save
        customer.billing_address_id = billing_address.id
        
        unless params[:same_address] == "1"
          shipping_address = Address.new
          shipping_address.label = "Address 2"
          shipping_address.first_name = params[:customer][:shipping_address][:first_name]
          shipping_address.last_name = params[:customer][:shipping_address][:last_name]
          shipping_address.company = params[:customer][:shipping_address][:company]
          shipping_address.street_1 = params[:customer][:shipping_address][:address_1]
          shipping_address.street_2 = params[:customer][:shipping_address][:address_2]
          shipping_address.city = params[:customer][:shipping_address][:city]
          shipping_address.state = params[:customer][:shipping_address][:state]
          shipping_address.zip = params[:customer][:shipping_address][:zip]
          shipping_address.phone = params[:customer][:shipping_address][:phone]
          shipping_address.customer_id = customer.id
          shipping_address.save
          customer.shipping_address_id = shipping_address.id
        else
          customer.shipping_address_id = billing_address.id
        end
        
        customer.save
        
        session[:customer] = customer.id
        redirect_back_or_default url_for( :controller => 'checkout', :action => 'review_cart' )
      end 
    end  
  end
  
  def signin
    title "Rocket Postcards: Customer Sign-In"
#    store_location_as(params[:redirect_to]) if params[:redirect_to]
    logger.debug "\n\n\n return to: #{session[:return_to]}\n\n\n\n"
    logger.debug "\n\n\n url_for_redirect: #{url_for_redirect('yayo')}\n\n\n\n"
    if request.post?
      if customer = Customer.authenticate( params[:email], params[:password] )
        make_signed_in(customer)
      else
        session[:customer] = nil
        flash[:error] =  "We weren't able to find an account for that email address and password."
      end
    end
    
    respond_to do |format|
      format.html do
        signin_html
      end
      format.js { signin_js }
    end
  end
  
  def signin_html
    logger.debug "\n\n\n return to: #{session[:return_to]}\n\n\n\n"
    logger.debug "\n\n\n url_for_redirect: #{url_for_redirect('yayo')}\n\n\n\n"
    if signed_in?
      if @current_customer.confirm_updated
        redirect_back_or_default(review_cart_url)
      else
        redirect_to confirm_updated_url(:return_to => url_for_redirect(review_cart_url))
      end
    end
  end
  
  
  def signin_js
    if signed_in?
      url = url_for_redirect(review_cart_url)
      logger.debug "\n\n\n return to: #{session[:return_to]}\n\n\n\n"
      logger.debug "\n\n\n url_for_redirect: #{url_for_redirect('yayo')}\n\n\n\n"
      if @current_customer.confirm_updated
        js_redirect_back_or_default(review_cart_url)
      else
        render :update => true, :layout => false do |page|
          page << "Modalbox.show('Confirm','#{confirm_updated_url(:return_to => url)}', {height: 500, width: 490})"
        end
      end
    else
      render(:update => true, :layout => false) { |p| p.redirect_to customer_signin_url }
    end
  end
  
  def signin_modal
    store_location_as(params[:redirect_to])
    render(:action => 'signin_modal', :layout => false)
  end
  
  def signout
    session[:customer] = nil
    redirect_to home_url
  end
  
  def profile
    @page_title = "Rocket Postcards - My Account"
    
    if params[:update] == "email"
      if params[:email] and not params[:email].empty? and params[:email_confirm] and not params[:email_confirm].empty?
        if params[:email] == params[:email_confirm]
          @current_customer.email = params[:email]
          @current_customer.save
          params[:email] = params[:email_confirm] = nil
        else
          flash.now[:error] = "You must confirm your new email address in order to save changes."
        end
      else
        flash.now[:error] = "You must enter and confirm your new email address if you wish to save it."
      end
    end
  
    if params[:update] == "password"
      if params[:password] and not params[:password].empty? and params[:password_confirm] and not params[:password_confirm].empty?
        if params[:password] == params[:password_confirm]
          @current_customer.password = params[:password]
          @current_customer.save
          params[:password] = params[:password_confirm] = nil
        else
          flash.now[:error] = "You must confirm your new password in order to save changes."
        end
      else
        flash.now[:error] = "You must enter and confirm your new password if you wish to save it."
      end
    end
  
  end
  
  def edit_address
    @page_title = "Rocket Postcards - My Account"
    
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
      
      redirect_to :action => 'profile'
    end
  end
  
  def address_book
    @page_title = "Rocket Postcards - My Account"
    
    if request.post? and params[:ship_to_address]
      @current_customer.shipping_address_id = params[:ship_to_address].to_i
      @current_customer.save
      logger.debug "setting address id"
      redirect_to :action => 'profile'
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
    
    redirect_to :action => 'address_book'
  end
  
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
  
  
end
