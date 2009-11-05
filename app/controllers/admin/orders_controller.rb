class Admin::OrdersController < Admin::AdminController
  caches_page :show_image  
  layout 'main'
  before_filter :signin_required, :except => [:show_image]  
  access_control [:show, :change_address] => 'admin | general'  

  def create
	  @invoice = Invoice.find(params[:invoice_id])
	  if params[:design]
	    order = DesignOrder.new(:invoice => @invoice, :address => @invoice.customer.shipping_address)
	    if params[:order_id]
	      order.order = Order.find(params[:order_id])
	    end  
	    order.save
	    redirect_to view_design_order_url(:id => order.id)
	  else
	    order = Order.new(:invoice => @invoice, :address => @invoice.customer.shipping_address)
  	  order.save
  	  redirect_to show_order_url(:id => order.id)
	  end
  end
	
  def change_product
    update_order
  end
	
  def update_order
	  @record = Order.find_by_id(params[:order_id])
	  old_product_id = @record.product_id.to_i
	  product = Product.find_by_sku(params[:product_sku])
	  cart_product = CartProduct.new(Cart.new(@record.invoice.customer))
	  cart_product.product = product
	  cart_product.soft_options = ( params[:product_options] || product.default_option_values )
	  cart_product.quantity = params[:quantity].to_i
	  cart_product.shipping_address_id = @record.address_id
	  cart_product.mailing_quantity = params[:mailing_quantity].to_i
	  cart_product.shipping_method_id = params[:shipping_method_id].to_i
	  cart_product.reseller_id = params[:reseller_id]
	  cart_product.mail_house = (params[:mail_house].to_i == 1)
	  cart_product.get_ups_rates
	  
	  if params[:charges]
	    params[:charges].each do |i, charge_hash|
	      unless charge_hash[:name].to_s.empty? or charge_hash[:price].to_f < 0.1 
	        cart_product.extra_charges << ExtraCharge.new(:name => charge_hash[:name], :price => charge_hash[:price])
	      end
	    end
	  end
	  
	  @record = cart_product.to_order(@record)
	  @record.status = params[:order][:status]
	  @record.submit_method_id = params[:submit_method_id]
	  @record.batch = params[:batch]
	  @record.payment_type = params[:payment_type]
	  @record.payment.amount_paid = params[:amount_paid]
	  @record.payment_approved = params[:payment_approved]
	  @record.payment.save
	  
	  @record.invoice.customer.issues = params[:issues]
	  @record.invoice.customer.save
	  @record.account_rep = params[:account_rep]
	  @record.tax_free_verified = (params[:tax_free_verified] == '1')
	  
	  @record.save!
	  @record.reload
	  
	  respond_to do |format|
        format.html { redirect_to show_order_url(:id => @record.id)}
        format.js do 
    	  render :update => true, :layout => false do |page|
    	    page['dates'].update(render(:partial => 'dates'))
    	    page['totals'].update render(:partial => 'totals')
    	    page['shipping_price'].update(number_to_currency(@record.shipping_price))
      
            options = (@record.product.product_options + @record.product_option_values.collect(&:product_option)).uniq
    	    page['lineitems'].update render(:partial => 'lineitems', :locals => {:options => options})
    	    page['specs'].update(render(:partial => 'specs', :locals => {:options => options}))
	    
    	    page['billingAddressTable'].update render(:partial => 'address_table', 
                                                  :locals => { :address => @record.invoice.address })
            page['shippingAddressTable'].update render(:partial => 'address_table', 
                                                  :locals => { :address => @record.address })
                                              
            page << "new Form.EventObserver($('product_form'), updateOrder); "
    	  end	  
        end
	  end
	end
	
	def change_design
	  @record = DesignOrder.find(params[:id])
	  
	  cart_design = CartDesign.new(Cart.new(@record.invoice.customer))
	  
	  cart_design.soft_options = params[:design_options]
    cart_design.custom_name = params[:custom_name]
    cart_design.copy = params[:copy]
    cart_design.comments = params[:comments]
    cart_design.for_product_id = params[:product_id]
	  
	  @record = cart_design.to_order(@record)
	  @record.designer = params[:designer]
	  @record.status = params[:status]
	  @record.payment_type = params[:payment_type] if params[:payment_type] and not params[:payment_type].empty?
	  @record.payment_approved = (params[:payment_approved] == 'true')	if params[:payment_approved]
	  
	  if params[:amount_paid] and not params[:amount_paid].empty? and @record.payment
	    @record.payment.amount_paid = params[:amount_paid].to_f
	  end
	  
	  @record.save!
	  @record.payment.save if @record.payment
	  
	  @record.reload
	  

	  render :update => true, :layout => false do |page|
	    page['design_options'].update render(:partial => 'design_options')
	    page['moneyStuff'].update render(:partial => 'design_totals')
	  end
	end
	
	def reorder
	  old_order = Order.find(params[:id])
	  new_order = old_order.clone
	  new_order.product_option_values.clear
	  new_order.save
	  old_order.product_option_values.each do |pov|
	    new_pov = pov.clone
      new_pov.order_id = new_order.id
      new_pov.save
	  end
	  redirect_to show_order_url(:id => new_order.id)
	end
	
	def reprint
	  old_order = Order.find(params[:id])
	  new_order = old_order.clone
	  new_order.make_reprint
	  new_order.save
	  old_order.product_option_values.each do |pov|
	    new_pov = pov.clone
      new_pov.order_id = new_order.id
      new_pov.save
	  end
	  redirect_to show_order_url(:id => new_order.id)
	end
	
  def show  

    @record = Order.find(params[:id])
    
    if query = session[:order_query]
      sort = query[:order].clone.downcase
      operators = (sort.sub!(' desc', '') ? ['>=', '>'] : (sort.sub!(' asc', ''); ['<=', '<']))
      if query[:conditions]
        conditions = query[:conditions].clone
        conditions[0] = conditions.first + " AND ( #{sort} #{operators.first} (SELECT #{sort} FROM orders WHERE orders.id=#{@record.id}))"
        conditions[0] += " AND (orders.id < #{@record.id})" unless sort.match(".id")
      else
        conditions = "( #{sort} #{operators.first} (SELECT #{sort} FROM orders WHERE orders.id=#{@record.id})) AND (orders.id #{operators.last} #{@record.id})"
      end
      
      offset = Order.count(:select => "DISTINCT (orders.id)", :conditions => conditions, :joins => query[:joins])      
      
      
      @previous_record = Order.find(:first, :select => query[:select], :conditions => query[:conditions], 
                                :joins => query[:joins], :order => query[:order], :offset => (offset - 1)) unless offset == 0
                                
      @next_record = Order.find(:first, :select => query[:select], :conditions => query[:conditions], 
                                :joins => query[:joins], :order => query[:order], :offset => (offset + 1))
    end
  end
  
  def show_design
    @record = DesignOrder.find(params[:id])
  end
  
  def change_address
    if params[:design]
      @record = DesignOrder.find(params[:order_id])
    else
      @record = Order.find(params['order_id'])
    end
    
    address = Address.find_by_id(params['address_id'])

    if params['address_type'] == 'billing'
      @record.invoice.address = address
    elsif params['address_type'] == 'shipping'
      @record.address = address
    end  

    @record.invoice.save!
    @record.save!
    
    render :update => true, :layout => false do |page|  
      page['billingAddressTable'].update render(:partial => 'address_table', 
                                              :locals => { :address => @record.invoice.address })
      page['shippingAddressTable'].update render(:partial => 'address_table', 
                                              :locals => { :address => @record.address })
      page['moneyStuff'].update render(:partial => (params[:design] ? 'design_totals' : 'totals'))
    end
      
  end
  
  def add_comment
    @record = Order.find(params[:order_id])
    @record.comments << Comment.new(:comment => params[:comment], :user => @current_user, :kind => 'PrePress')
    render :update => true, :layout => false do |page| 
      page.redirect_to show_order_url(:id => @record.id)
    end
  end
  
  
  def image_original
    @image = Image.find(params[:id])
    response.headers['Content-Type'] = "application/force-download" 
    response.headers['Content-Disposition'] = "attachment; filename=\"#{File.basename(@image.filename)}\"" 
    #response.headers["X-Sendfile"] = @image.filename
    #response.headers['Content-length'] = File.size(@image.filename)
    send_file(@image.filename)
    #render :nothing => true
  end

  def download_list
    @list = List.find(params[:id])
    response.headers['Content-Type'] = "application/force-download" 
    response.headers['Content-Disposition'] = "attachment; filename=\"#{File.basename(@list.filename)}\"" 
    #response.headers["X-Sendfile"] = @image.filename
    #response.headers['Content-length'] = File.size(@image.filename)
    send_data(@list.data, :filename => @list.filename)
    #render :nothing => true
  end

  def upload
    @order = Order.find(params[:order_id])

    if params[:picture][:uploaded_data] != ""
      #p params[:picture][:uploaded_data]
      @picture = Picture.new(params[:picture])
      @picture.side = params[:side]
      @picture.order_id = @order.id
      @picture.save
      redirect_to url_for({:controller => 'orders', :action	=>	'show', :view 	=>	'detail', :id	=>	@order.id})
      return
    end
#    if params[:new_image] and params[:new_image][:data].kind_of?( Tempfile )
#      image = Image.add_to_order(@order, params[:new_image][:side], params[:new_image][:data])
#      @order.save
#      redirect_to url_for({:controller => 'orders', :action	=>	'show', :view 	=>	'detail', :id	=>	@order.id})
#      return
#    end
    render :nothing => true
  end

  def generate_conditions(table_hash)
    conditions = nil
    column_conditions = {}
    
    if params[:search]
      table_hash.each do |table, columns|
        next if columns.nil?
        columns.each do |column|
          if params[:search][column] and not params[:search][column].empty?
            (column_conditions[column] ||= []) << ["(#{table}.#{column} LIKE ?)", params[:search][column]] 
          end
        end
      end
    
      conditions = column_conditions.inject([[]]) do |conds, column|
        conds.first << column.last.collect { |c| c.first }.join(' OR ')
        column.last.length.times { conds << (column.last.last.last + '%') }
        conds
      end
    
      if job_number = params[:search][:full_job_number] and not job_number.empty?
        if matches = job_number.match(/(\d+)\D?(\d*)/) and captures = matches.captures
          if captures.last.empty?
            conditions.first << "orders.invoice_id=?"
            conditions << captures.first
          else
            conditions.first << "orders.invoice_id=? AND orders.job_number=?"
            conditions << captures.first; conditions << captures.last
          end
        end
      end
      
      if quantity = params[:search][:quantity] and not quantity.empty?
        if matches = quantity.match(/(\d+)\D*(\d*)/) and captures = matches.captures
          if captures.last.empty?
            conditions.first << "orders.quantity=?"
            conditions << captures.first
          else
            conditions.first << "orders.quantity >= ? AND orders.quantity <= ?"
            conditions << captures.first; conditions << captures.last
          end
        end
      end
      
      conditions[0] = conditions.first.collect{ |c| '(' + c + ')' }.join(' AND ')
      conditions = nil if conditions.length == 1 and conditions.first.empty?
    end
    
    conditions
  end

  def advanced_search
    conditions = generate_conditions(tables)
    
    params[:sort] ||= 'orders.id DESC'
    
    pager_params = {  :select => "DISTINCT orders.*, proof_method.label as proof_method_name, paper.label as paper, coating.label as coating, products.product_code, products.title, invoices.customer_id, invoices.address_id AS billing_address_id, customers.first_name, customers.last_name, customers.company, customers.email, customers.phone",
                      :joins => "LEFT JOIN order_product_option_values AS proof_method ON (orders.id=proof_method.order_id AND proof_method.title = 'Proofing') LEFT JOIN order_product_option_values AS paper ON (orders.id=paper.order_id AND paper.title = 'Paper') LEFT JOIN order_product_option_values AS coating ON (orders.id = coating.order_id AND coating.title='Coating') LEFT JOIN addresses as shipping_address ON orders.address_id=shipping_address.id LEFT JOIN invoices on invoices.id=orders.invoice_id LEFT JOIN customers on customers.id=invoices.customer_id LEFT JOIN products on products.id=orders.product_id LEFT JOIN addresses as billing_address on invoices.address_id=billing_address.id LEFT JOIN payments ON payments.order_id=orders.id",
                      :conditions => conditions,
                      :order => params[:sort]
                      #:include => [:address, :product, :payments, {:invoice => [:address, :customer]}] 
                      }
    
    
    #count = Order.count(:conditions => conditions )
    
    logger.debug conditions.to_yaml
    logger.debug params[:sort]
    
    session[:order_query] = pager_params
    
    @pages, @records = paginate :orders, pager_params
    
    respond_to do |wants|
      wants.html {
       render :action => 'list'
      }
      
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['data'].replace render(:partial => 'list_table')
          page['paginator'].replace render(:partial => 'admin/components/paginator')
          page['sort'].update render(:partial => 'sort')
        end        
      }
    end    

  end
  
  def design_search    
    params[:sort] ||= 'design_orders.id DESC'
    
    pager_params = {  :select => "design_orders.*, invoices.customer_id, invoices.address_id AS billing_address_id, customers.first_name, customers.last_name, customers.company, customers.email, customers.phone",
                      :joins => "LEFT JOIN invoices on invoices.id=design_orders.invoice_id LEFT JOIN customers on customers.id=invoices.customer_id LEFT JOIN addresses as billing_address on invoices.address_id=billing_address.id LEFT JOIN payments ON payments.design_order_id=design_orders.id",
                      :conditions => generate_conditions(design_tables),
                      :order => params[:sort],
                      :per_page => 20
                      
                      #:include => [:address, :product, :payments, {:invoice => [:address, :customer]}] 
                      }
    
    @pages, @records = paginate :design_orders, pager_params
    
    respond_to do |wants|
      wants.html {
       render :action => 'list_design'
      }
      
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['data'].replace render(:partial => 'list_design')
          page['paginator'].replace render(:partial => 'admin/components/paginator')
          page['sort'].update render(:partial => 'sort_design')
        end        
      }
    end
    
  end
  
  
  def bump
    @record = Order.find(params[:id])
    @record.bump_dates(params[:offset].to_i)
    @record.save
    
    render(:update => true, :layout => false) do |page|
      page['dates'].update(render(:partial => 'dates'))
    end
  end
  
  def paid_now
    @record = Order.find(params[:id])
    @record.paid_at = Time.now
    @record.save
    
    render(:update => true, :layout => false) do |page|
      page['paid_at'].update(@record.paid_at.strftime("%m/%d/%y"))
    end
  end
    
  def design_paid
    @record = DesignOrder.find(params[:id])
    if params[:commission]
      @record.commission_paid_at = Time.now
    else
      @record.paid_at = Time.now
    end
        
    @record.save!
    
    render(:update => true, :layout => false) do |page|
      page['commission_paid_at'].update(@record.commission_paid_at.strftime("%m/%d/%y")) if @record.commission_paid_at
      page['paid_at'].update(@record.paid_at.strftime("%m/%d/%y")) if @record.paid_at
    end
  end
    
  def invoiced_now
    @invoice = Invoice.find(params[:id])
    @invoice.sent_at = Time.now
    @invoice.save
    
    render(:update => true, :layout => false) do |page|
      page['invoiced_at'].update(@invoice.sent_at.strftime("%m/%d/%y"))
    end
  end
  
  def capture_payment
    @payment = AbstractPayment.find(params[:id])
    @payment.capture!
    
    render(:update => true, :layout => false) do |page|
      if @payment.captured
        order = (@payment.order or @payment.design_order)  
        order.reload
        page['captured_at'].update(@payment.captured_at.strftime("%m/%d/%y"))
        page['paid_at'].update(order.paid_at.strftime("%m/%d/%y")) if order.paid_at
        page['amount_paid'].value = order.amount_paid
      else
        page << "alert('There was an error capturing the payment.')"
      end
    end
  end

  def show_image
    headers['Cache-Control'] = 'public'
    
    image_options = params.symbolize_keys
   
    
    begin
      img = Image.find(params[:id])
      img.process!(image_options)
      render_flex_image(img)
    rescue ActiveRecord::RecordNotFound
      render(:text => "<h1>Image (#{params[:id]}) not Found</h1>", :status => 404)
    rescue Magick::ImageMagickError
      render(:text => "<h1>Image (#{params[:id]}) not found on disk.</h1>", :status => 404)
    end
  end
    
  
  def remove_image
    @image = Image.find(params[:id])
    @image.destroy
    @record = @image.order
    render(:update => true, :layout => false) do |page|
      page['images'].update(render(:partial => 'images'))
    end
  end
  
  def update_press_notes
  
    @order = Order.find(params[:id])
    @order.press_notes = params[:press_notes]
    @order.save
  
    render :update do |page|
          
	       page.alert(" Your Press Comments #{params[:press_notes]}is successfully saved ")
     end
  end
  
  def update_runs
    @record = Order.find(params[:id])
    @record.run_a = params[:run_a]
	  @record.run_b = params[:run_b]
	  @record.save
	  render :nothing => true
  end
  
  def create_folder
    @order = Order.find params[:id]
    @order.create_folder
    render(:update => true, :layout => false) do |page|
      page << "alert('Stored files in folder #{@order.full_job_number}')"
    end
  end
  
  def update_address
    @order = Order.find(params[:order_id])
    @address  = Address.find(params[:id])
    if params[:address] and params[:address][@address.id.to_s]
		  params[:address][@address.id.to_s].each_pair do |field, value|
  		  @address.send("#{field}=".to_sym, value)
  		end
  		@address.save
    end
    respond_to do |format|
      format.js { render :nothing => true }
      format.html { redirect_to show_order_url(:id => @order.id)}
    end
  end

  # Added by SUHAS - Sept 26, 2008
  def actual_image
    render :layout => false
  end
  
  private
  
  def tables
    { 'billing_address' => ['first_name', 'last_name', 'company', 'city', 'zip', 'state', 'street_1'],
      'shipping_address' => ['first_name', 'last_name', 'company', 'city', 'zip', 'state', 'street_1'],
      'orders' => ['status', 'product_sku', 'batch', 'run_a', 'run_b', 'shipping_method_id'],
      'payments' => ['type'],
      'customers' => ['id', 'first_name', 'last_name', 'company', 'email']
    }
  end
  
  def design_tables
    tables.update({ 'orders' => nil, 'shipping_address' => nil, 'design_orders' => ['status', 'designer'] })
  end  
          
end
