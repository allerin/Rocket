class Admin::ReportsController < Admin::AdminController  
  layout 'main'
  before_filter :signin_required
  #access_control [:show, :change_address] => 'admin | general'
  
  def list 
    respond_to do |wants|
      wants.html {}
    end
  end
  
  def form   
    render(:update => true, :layout => false) do |page|
      page['subnav'].update(render(:partial => "admin/reports/forms/menu"))
      page['report_form'].update(render(:partial => "admin/reports/forms/#{params[:form]}"))
    end
  end
  
  def pickup_list       
    conditions = ["orders.shipping_method_id=?", pickup_method.id]
    if params[:batch]
      conditions.first << " AND orders.batch=? "
      conditions << params[:batch]
    end
    if params[:completed]
      conditions.first << " AND orders.status=?"
      conditions << "Boxed/Completed"
    elsif params[:new]
      conditions.first << " AND orders.status NOT IN ('" + Order.statuses[Order.statuses.index('Boxed/Completed')..-1].join("','") + "')"
    end
    
      @orders = Order.find( :all, :conditions => ["batch =?",params[:batch]],
                            :include => [:address, {:invoice => [:address, :customer]}],
                            :order => "orders.invoice_id, orders.job_number")
                          
        if  params[:batch]== "3" and params[:Search_by_status]== "Boxed/Completed"
         
           @orders = Order.find(:all,  :conditions => ["status=?",'Boxed/Completed'])
         end  
    respond_to do |wants|
      wants.html { 
        render(:template => "admin/reports/lists/pickup_print", :layout => 'print') if params[:completed]
        render(:template => "admin/reports/lists/pickup_invoices", :layout => false) if params[:new]
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/pickup"))
        end
      }
    end
  end
  
  def pickup_make_completed
     @orders = Order.find(:all, :conditions => [("orders.batch=? AND orders.shipping_method_id=? AND orders.status NOT IN ('" + Order.statuses[Order.statuses.index('Boxed/Completed')..-1].join("','") + "')"), params[:batch], pickup_method.id])
     @orders.each do |order|
      order.status = 'Boxed/Completed'
      order.save
    end
    
    render(:update => true, :layout => false) do |page|
      page << "alert('Made #{@orders.length} orders Boxed/Completed.')"
    end
  end
  
  def shipping_list
     
    conditions = ["orders.shipping_method_id=? AND orders.batch=?", params[:shipping_method_id], params[:batch]]
    if params[:invoices]
      conditions.first << " AND orders.status NOT IN ('" + 
                          Order.statuses[Order.statuses.index('Shipped')..-1].join("','") + "')"
    end
     if params[:shipping_method_id] == "8"
      @orders = Order.find( :all, :conditions => ["batch=?", params[:batch]])
   
   else
    @orders = Order.find( :all, :conditions => conditions,
                          :include => [:address, {:invoice => [:address, :customer]}],
                          :order => "orders.shipping_method_id")
                          end
                         
    respond_to do |wants|
      wants.html { 
        render(:template => "admin/reports/lists/shipping_print", :layout => "print") if params[:list]
        render(:template => "admin/reports/lists/pickup_invoices", :layout => false) if params[:invoices]
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/shipping_status"))
        end
      }
    end
  end
  
  def shipping_make_shipped
   
    @orders = Order.find( :all, :conditions => [("orders.batch=? AND orders.shipping_method_id=? AND orders.status NOT IN ('" + Order.statuses[Order.statuses.index('Shipped')..-1].join("','") + "')"), params[:batch], params[:shipping_method_id]])
    
    @orders.each do |order|
      order.status = 'Shipped'
      order.save
    end
    
    render(:update => true, :layout => false) do |page|
      page << "alert('Made #{@orders.length} orders Shipped.')"
    end
    
  end
  
  def shipping_export
   
    require 'fastercsv'
    comparison = (params[:method] == 'shipping' ? '!=' : '=')
    @orders = Order.find(:all,  :conditions => ["orders.batch=? AND orders.shipping_method_id #{comparison} ?", 
                                params[:batch], pickup_method.id],
                                :order => 'orders.shipping_method_id, orders.invoice_id, orders.job_number')
    
    csv_string = FasterCSV.generate do |csv|
    csv << ['First Name', 'Last Name', 'Street 1', 'Street 2','City','Compnay','Country','email','Phone','State','Zip','Shippin Method','Full Job Number']
        
      @orders.each do |order|
        if address = (order.address or order.invoice.address)
          csv << [address.first_name, address.last_name, (address.street_1.to_s + ' ' + address.street_2.to_s),
                  address.city, address.company, address.country, order.invoice.customer.email, address.phone, address.state,
                  address.zip, (order.shipping_method.name rescue ''), order.full_job_number]
        else
        
        end
      end
    end
    
    send_data csv_string, :type => 'text/csv', :filename => (params[:batch] + ' ' + params[:method].capitalize + ' Export.txt')
  end
  
  def run_list
      if params[:run]== "" || params[:run] == nil
        @orders = Order.find(:all, :conditions => ["orders.batch=? ", params[:batch]])
      else
       @orders = Order.find(:all, :conditions => ["orders.batch=? AND (orders.run_a=? OR orders.run_b=?)", params[:batch], params[:run], params[:run]])
      end  
     
    respond_to do |wants|
      wants.html {
        @title = "Batch #{params[:batch]} Run #{params[:run]} Report"
        render(:template => "admin/reports/lists/run_print", :layout => 'report_print')
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/run"))
        end
      }
    end
  end
  
  def run_export
  
    require 'fastercsv'
    @orders = Order.find(:all, :conditions => ["orders.batch=? ", params[:batch]])
    
    #  tab delimited TEXT file  - Sept 18, 2008
    csv_string = FasterCSV.generate(:col_sep => "\t") do |csv| #{|csv| csv << ['Job Number', 'product_sku', 'quantity', 'color_code']}
      csv << ['Job Number', 'product_sku', 'quantity', 'color_code']
      @orders.each do |order|
        csv << [order.full_job_number, order.product_sku, order.quantity, order.color_code]
      end
    end
    
    send_data csv_string, :type => 'text/txt', :filename => (params[:batch] +' Rocket.txt')
    
    #  tab delimited CSV file
#    csv_string = FasterCSV.generate do |csv|
#       csv << ['Job Number', 'product_sku', 'quantity', 'color_code']
#      @orders.each do |order|
#     
#        csv << [order.full_job_number, order.product_sku, order.quantity, order.color_code]
#      end
#    end
#    
#    send_data csv_string, :type => 'text/csv', :filename => (params[:batch] +' Rocket.csv')
  end
  
  def add_press_comment
      
    @order = Order.find(params[:order_id])
    
    @order.comments << Comment.new(:kind => params[:kind], :comment => params["new_press_comment_#{@order.id}"], :user => @current_user)
    @order.save
    
    render(:update => true, :layout => false) do |page|
      page["order_#{@order.id}"].update render(:partial => "admin/reports/lists/#{params[:view]}", :locals => {:order => @order})
    end
  end
  
  def change_run  
    @order = Order.find(params[:order_id])
    @order.send("run_#{params[:side]}=", params[:run])
    @order.save
    
    render(:update => true, :layout => false) do |page|
    end
  end

  def change_status  
    @order = Order.find(params[:order_id])
    @order.status = params[:status]
    @order.pickedup_date = Time.now
    @order.save
    render(:update => true, :layout => false) do |page|
      if @order.status == 'Picked Up'
        page.replace_html "pickup_date_#{@order.id}", "Picked Up Date: #{@order.pickedup_date.strftime('%m/%d/%y')}"
      end
    end
  end

  def status_list
   
     
     if params[:Search_by_status]=="" ||   params[:Search_by_status]==nil
      @orders = Order.find( :all, :conditions => ["batch=?", params[:batch]],:order => Order.statuses.collect { |s| "(orders.status='#{s}') DESC" }.join(','))
    
   else
    @orders = Order.find(:all,  :conditions => ["orders.batch=? and  orders.status =?", params[:batch],params[:Search_by_status]],
                                :order => Order.statuses.collect { |s| "(orders.status='#{s}') DESC" }.join(','))
  
  end
    respond_to do |wants|
      wants.html {
        @title = "Batch #{params[:batch]} Status Report"
        render(:template => "admin/reports/lists/status_print", :layout => 'report_print')
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/status"))
        end
      }
    end
  end
  
  def tax_list
  
    month = Time.local(*params[:month].match(/(\d+)\/(\d+)/).captures.collect(&:to_i).reverse)
    @orders = Order.find(:all,  :conditions => ["orders.paid_at > ? AND orders.paid_at < ?", month, month + 30.days])
    
    respond_to do |wants|
      wants.html {
        @title = "#{params[:month]} Sales Tax Report"
        render(:template => "admin/reports/lists/tax_print", :layout => 'report_print')
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/tax"))
        end
        
      }
    end
  end
  
  def terms_list
   
    @orders = Order.find(:all,  :include => [:payments, {:invoice => :customer}],
                                :order => "customers.company",
                                :conditions => ["payments.type='TermsPayment' AND orders.paid_at IS NULL"])
    
    respond_to do |wants|
      wants.html {
        @title = "Terms Report"
        render(:template => "admin/reports/lists/terms_print", :layout => 'report_print')
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/terms"))
        end
        
      }
    end
  end
  
  def rep_list
  
    conditions = [[]]
    if params[:sales_rep] and not params[:sales_rep].empty?
      conditions.first << "orders.account_rep=?"
      conditions << params[:sales_rep]
    end
    if params[:name] and not params[:name].empty?
      conditions.first << "customers.first_name LIKE ? OR customers.last_name LIKE ? OR addresses.first_name LIKE ? OR addresses.last_name LIKE ?"
      4.times { conditions << params[:name] + '%' } 
    end
    if params[:company] and not params[:company].empty?
      conditions.first << "customers.company LIKE ? OR addresses.company LIKE ?"
      2.times { conditions << '%' + params[:company] + '%' } 
    end
    if params[:start_date] and not params[:start_date].empty? and ParseDate.parsedate(params[:start_date]).first 
      conditions.first << "invoices.created_at >= ?"
      conditions << Time.local(*ParseDate.parsedate(params[:start_date]))
    end
    if params[:end_date] and not params[:end_date].empty? and ParseDate.parsedate(params[:end_date]).first 
      conditions.first << "invoices.created_at <= ?"
      conditions << (Time.local(*ParseDate.parsedate(params[:end_date])) + 1.day)
    end
    
    unless conditions.first.empty?
      conditions[0] = '(' + conditions.first.join(') AND (') + ')'
      @orders = Order.find(:all, :include => [{:invoice => [:address, :customer]}, :address], :conditions => conditions, :order => "orders.account_rep")
    else
      @orders = []
    end  
    
    respond_to do |wants|
      wants.html {
        @title = "Sales Rep Report"
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/rep"))
        end
      }
    end
  end
  
  def payment_list
    conditions = [[]]
    if params[:method] and not params[:method].empty?
      conditions.first << "payments.type=?"
      conditions << params[:method] + 'Payment'
    end
    if params[:batch] and not params[:batch].empty?
      conditions.first << "orders.batch=?"
      conditions << params[:batch]
    end
    if params[:start_date] and not params[:start_date].empty? and ParseDate.parsedate(params[:start_date]).first 
      conditions.first << "invoices.created_at >= ?"
      conditions << Time.local(*ParseDate.parsedate(params[:start_date]))
    end
    if params[:end_date] and not params[:end_date].empty? and ParseDate.parsedate(params[:end_date]).first 
      conditions.first << "invoices.created_at <= ?"
      conditions << (Time.local(*ParseDate.parsedate(params[:end_date])) + 1.day)
    end
    
    unless conditions.first.empty?
      conditions[0] = '(' + conditions.first.join(') AND (') + ')'
      @orders = Order.find(:all, :include => [:payments, :invoice], :conditions => conditions)
    else
      @orders = []
    end  
    
    respond_to do |wants|
      wants.html {
        @title = "Payment Report"
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/payment"))
        end
      }
    end
    
  end
  
  def capture_list
  
    conditions = [[]]
    conditions.first << "payments.type='CreditPayment' AND payments.approved = 1"
    if params[:batch] and not params[:batch].empty?
      conditions.first << "orders.batch=?"
      conditions << params[:batch]
    end
    
    if params[:start_date] and not params[:start_date].empty? and ParseDate.parsedate(params[:start_date]).first
      conditions.first << "orders.created_at >= ?"
      conditions << Time.local(*ParseDate.parsedate(params[:start_date]))
    end
      
    if params[:end_date] and not params[:end_date].empty? and ParseDate.parsedate(params[:end_date]).first
      conditions.first << "orders.created_at <= ?"
      conditions << (Time.local(*ParseDate.parsedate(params[:end_date])) + 1.day)
    end  
    
    unless params[:captured] and params[:captured] == '1'
      conditions.first << "(payments.captured IS NULL OR payments.captured = '0')"
    end
    
    conditions[0] = '(' + conditions.first.join(') AND (') + ')'
    @orders = Order.find(:all, :include => [:payments], :conditions => conditions, :limit => 100, :order => "orders.id desc")
    
    respond_to do |wants|
      wants.html {}
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/capture"))
        end
      }
    end    
  end
  
  def sort
      if params[:id]=='1'
         @orders = Order.find(:all,  :conditions => ["batch=?",params[:batch_id]],
                                :order => 'id DESC' )
      end
      if params[:id]=='2'
         @orders = Order.find(:all,  :conditions => ["batch=?",params[:batch_id]],:order => 'run_a DESC')
                           
     end
      if params[:id]=='4'
         @orders = Order.find(:all,  :conditions => ["batch=?",params[:batch_id]],:order => 'run_b DESC')
                           
     end
     if params[:id]=='3'
        @orders = Order.find(:all,  :select => "DISTINCT orders.*, proof_method.label as proof_method_name, paper.label as paper, coating.label as coating, products.product_code, products.title, invoices.customer_id, invoices.address_id AS billing_address_id, customers.first_name, customers.last_name, customers.company, customers.email, customers.phone",
                      :joins => "LEFT JOIN order_product_option_values AS proof_method ON (orders.id=proof_method.order_id AND proof_method.title = 'Proofing') LEFT JOIN order_product_option_values AS paper ON (orders.id=paper.order_id AND paper.title = 'Paper') LEFT JOIN order_product_option_values AS coating ON (orders.id = coating.order_id AND coating.title='Coating') LEFT JOIN addresses as shipping_address ON orders.address_id=shipping_address.id LEFT JOIN invoices on invoices.id=orders.invoice_id LEFT JOIN customers on customers.id=invoices.customer_id LEFT JOIN products on products.id=orders.product_id LEFT JOIN addresses as billing_address on invoices.address_id=billing_address.id LEFT JOIN payments ON payments.order_id=orders.id",
                      :conditions => ["batch=?",params[:batch_id]],
                       :order=>' proof_method_name DESC '
                        )
    end
    respond_to do |wants|
      wants.html {
        @title = "Batch #{params[:batch]} Status Report"
        render(:template => "admin/reports/lists/status_print", :layout => 'report_print')
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/status"))
        end
      }
    end
    
  end
  
   def show_me
       @orders = Order.find(params[:id])
       @invoice_id= @orders.invoice_id
       @picture=Picture.find(:first,  :conditions => ["order_id=?",params[:id]])
       if @picture==nil
         @picture_1=Image.find(:first,  :conditions => ["order_id=?",params[:id]])
         @filename= @picture_1.filename
         icon = Magick::Image.read("#{RAILS_ROOT}/#{@filename}").first
       else
         icon = Magick::Image.read("#{RAILS_ROOT}/uploads/R#{@invoice_id}-1/#{@picture.filename}").first
        end
         send_data icon.to_blob, 
                                    :disposition => 'inline', 
                                    :type => "image/png" 
   end
    
    def find_by_status
   
        @orders = Order.find(:all,  :conditions => ["status=?",params[:Search_by_status]])
       if params[:status] 
        respond_to do |wants|
      wants.html {
        @title = "Batch #{params[:batch]} Status Report"
        render(:template => "admin/reports/lists/status_print", :layout => 'report_print')
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/status"))
        end
      }
    end
    else  
    respond_to do |wants|
      wants.html { 
        render(:template => "admin/reports/lists/pickup_print", :layout => false) if params[:completed]
        render(:template => "admin/reports/lists/pickup_invoices", :layout => false) if params[:new]
      }
      wants.js {
        render(:update => true, :layout => false) do |page|
          page['report_list'].update(render(:partial => "admin/reports/lists/pickup"))
        end
      }
    end
    end
    end
    
    def status_change
        @orders = Order.find(params[:id])
      
     
       @orders.update_attributes(:shipping_method_id=>params[:type])
        render(:update => true, :layout => false) do |page|
        page.alert "Status is Changed  " +  @orders.shipping_method.name
      end
    end
    
    def status_change_1
        @orders = Order.find(:all,  :conditions => ["batch=?",params[:batch_id]])
        for orders in @orders
        orders.update_attributes(:status=>params[:Search_by_status])
        end
        render(:update => true, :layout => false) do |page|
              page.alert " For batch Id " + params[:batch_id] + "Status is Changed To " +params[:Search_by_status] 
        end
    end
    
    def status_change_run
          @orders = Order.find(:all,  :conditions => ["batch=?",params[:batch_id]])
           
          if   params[:run_B] == nil || params[:run_B].length == 0
              for orders in @orders
                  orders.update_attributes(:status=>params[:run_A])
              
              end
              render(:update => true, :layout => false) do |page|
              page.alert " For batch Id " + params[:batch_id] + "Run_A is Changed To " +params[:run_A] 
        end
        else
            for orders in @orders
                orders.update_attributes(:status=>params[:run_B])
            end
            render(:update => true, :layout => false) do |page|
            page.alert " For batch Id " + params[:batch_id] + "Run_B is Changed To " +params[:run_B] 
        end
    end
    end

  # To update the time in 'Payment Report' Added by SUHAS - Sept 24, 2008
  def update_paid_date
    @order = Order.find(params[:order_id])
    @order.paid_at = Time.now
    @order.save
    render(:update => true, :layout => false) do |page|      
      page.replace_html "paid_at_#{@order.id}", "#{@order.paid_at.strftime('%m/%d/%y')}"
    end
  end
    
  private
  
  def pickup_method
    @pickup_method ||= ShippingMethod.find_by_name('Pick Up')
  end
  
end
