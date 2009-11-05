class Admin::InvoicesController < Admin::AdminController
	#model :invoice
	before_filter :signin_required
	layout 'main'
	
	def index
		redirect_to :action => 'show'
	end
	
	def create
	  @customer = Customer.find(params[:customer_id])
	  invoice = Invoice.new(:customer => @customer, :address => @customer.billing_address)
	  invoice.save
	  @records = [invoice]
	end
	
	def destroy
	  invoice = Invoice.find(params[:id])
	  invoice.destroy
	  respond_to do |format|
	    #format.html { redirect_to show_invoices_url(:view => 'list') }
	    format.js { render(:update => true, :layout => false) { |page| page.redirect_to show_invoices_url(:view => 'list') } }
	  end
	end
    
	def show
		
		@views = {'list' => 22, 'detail' => 1}
		
		if params[:id]
		  @view = 'detail'
		  params[:key] = 'invoices.id'
		  params[:value] = params[:id]
		elsif @views.keys.include?(params['view'])
			@view = params['view']
			request.session['view'] = @view
		elsif @views.keys.include?(request.session['view'])
			@view = request.session['view']
		else
			@view = @views.keys.first
		end
		
		per_page = @views[@view]
		
		if params[:all]
			request.session[:page] = nil
			request.session[:invoices_key] = nil
			request.session[:invoices_value] = nil
			key = nil
			value = nil
		elsif params[:key] != nil
			key = params[:key]
			value = params[:value]
			request.session[:invoices_key] = key
			request.session[:invoices_value] = value
			request.session[:page] = nil
		else
			key = request.session[:invoices_key]
			value = request.session[:invoices_value]
		end
		
		if params['sort'] != nil
			request.session[:sort] = params['sort']
		elsif request.session[:sort] != nil
			params['sort'] = request.session[:sort]
		end
		
		if params['page'] != nil
			request.session[:page] = params['page']
		elsif request.session[:page] != nil
			params['page'] = request.session[:page]
		end
				
		sort = params["sort"]
		sort ||= 'invoices.id DESC'
		
		pager_params = {
		  :order_by => sort,
		  :per_page => per_page,
		  :include => [:customer, :address],
#		  :join => "JOIN customers, addresses 
#		                 ON invoices.customer_id = customers.id AND 
#		                    addresses.id = address_id",
		  :select => "invoices.id, invoices.created_at, invoices.updated_at, " +
		             "invoices.customer_id, invoices.address_id, " +
		             "customers.first_name, customers.last_name, " + 
		             "customers.company, addresses.label"
		}
		
		pager_params[:conditions] = ["#{key} = ?", value] unless key.to_s.empty?
    
		@pages, @records = paginate :invoices, pager_params
		@loading = ""
		@complete = ""
		if request.xhr?
			render :partial => 'show' 
		end

	end
	
	def print
	  @invoice = Invoice.find(params[:id])
	  render :layout => false
	end

  def add_comment
    @record = Invoice.find(params[:invoice_id])
    @record.comments << Comment.new(:comment => params[:comment], :user => @current_user)
    render :update => true, :layout => false do |page|
      page.redirect_to view_invoice_url(:value => @record.id)
    end
  end
  
  def mark_as_sent
    @invoice = Invoice.find(params[:id])
    @invoice.sent_at = Time.now
    @invoice.save
    
    render :update => true, :layout => false do |page|
      page.redirect_to view_invoice_url(:key => 'invoices.id', :value => @invoice.id)
    end
  end
end
