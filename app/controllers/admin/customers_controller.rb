class Admin::CustomersController < Admin::AdminController
	#model :customer
	before_filter :signin_required
	layout 'main'
	
	
	def index
		redirect_to :action => 'show'
	end
    
	def show		
		@views = {'list' => 22, 'detail' => 1}		
		
	  @view = if @views.keys.include?(params[:view])
		          session[:view] = params[:view]
		        elsif @views.keys.include?(session[:view])
		          session[:view]
		        else
		          @views.keys.first
		        end

		per_page = @views[@view]
		
		if params['search'] != nil
			quicksearch = params['search']
			request.session[:quicksearch] = quicksearch

			request.session[:page] = nil
			request.session[:customer_id] = nil
			request.session[:customers_key] = nil
			request.session[:customers_value] = nil
		else
			quicksearch = request.session[:quicksearch]
		end
		
		key, value =  if params[:key]
		                session[:customers_page], session[:customer_id] = nil  
		                session[:customers_key], session[:customers_value] = params[:key], params[:value]
		              else
		                [ session[:customers_key], session[:customers_value] ]
		              end
		
    customer_id =  if params[:id]
		              session[:customer_id] = params[:id]
		            else
		              session[:customer_id]
		            end
		
    sort =  if params[:sort]
  	          session[:customers_sort] = params[:sort]
  	        elsif session[:customers_sort]
  	          session[:customers_sort]
  	        else
  	          'customers.id'
  	        end
		
		if params[:page]
			session[:customers_page] = params[:page]
		elsif session[:customers_page]
			params[:page] = session[:customers_page]
		end
				
		search_conditions = []
		if params[:all]
		  request.session[:quicksearch] = nil
			request.session[:page] = nil
			request.session[:customer_id] = nil
			request.session[:customers_key] = nil
			request.session[:customers_value] = nil
		elsif customer_id
		  search_conditions = ["id = ?", customer_id]
		elsif !key.to_s.empty?
		  search_conditions = ["#{key} = ?", value]
		elsif quicksearch && !quicksearch.empty?
			
			search_words = quicksearch.split(" ")
			search_fields = ['first_name', 'last_name']
			search_string = ''
			search_conditions = []
			
			search_words.each do |word|
				search_string.concat('(')
				search_fields.each do |field|
					search_string.concat('LOWER(' + field + ') LIKE ? OR ')
					search_conditions << word + '%'
				end
				search_string.chomp!(' OR ')
				search_string.concat(') AND ')
			end
			
			search_string.chomp!(' AND ')
			search_conditions.insert(0, search_string)
		
		end
		
		sort = params["sort"]
		sort ||= 'last_name, first_name'
		
		pager_params = {
		  :order_by => sort,
		  :per_page => per_page
		}
		
		pager_params[:conditions] = search_conditions unless search_conditions.empty?

		@pages, @records = paginate :customers, pager_params
		@loading = ""
		@complete = ""
		if request.xhr?
			render :partial => 'show' 
		end

	end
	
	def show_address
	  if params[:address_id] == 'new'
		  @address = Address.new(:customer_id => params[:customer_id])
		  @address.save
		else
		  @address = Address.find(params[:address_id])
		end
		render :partial => 'address' 
	end
	
	def update_customer_field
		customer = Customer.find(params[:customer_id])
		
		params[:record][customer.id.to_s].each_pair do |field, value|
		  customer.send("#{field}=".to_sym, value)
		end
		
		customer.save

		render :nothing => true
	end
	
	# Modified by SUHAS - Sept 30, 2008
	def update_address_field
	  @customer = Customer.find(params[:customer_id])
    
	  if params[:id] == 'new'
      conditions = (params[:id] == 'new')    
	  else
      id = params[:id]
	  end
	  
	  unless conditions
      @address = Address.find(id)
      
  	  if @address.id == @customer.billing_address_id
        if params[:address] and params[:address][@address.id.to_s]
    		  params[:address][@address.id.to_s].each_pair do |field, value|
      		  @address.send("#{field}=".to_sym, value)
      		end
      		@address.save
  	    end
  	    @record = @customer
  	    render :update => true, :layout => false do |page|
  		    page["address_selected"].show
  		    page["address_selected"].update render(:partial => 'address')
  		    #page['address_option'].update render(:partial => 'address_option')
  		    page["new_address_selected"].hide
  	    end
  	    #render :nothing => true
  	  else
        @customer.billing_address = @address
  	    @customer.save
  	    @record = @customer
  	    render :update => true, :layout => false do |page|
  		    page["address_selected"].show
  		    page["address_selected"].update render(:partial => 'address')
  		    #page['address_option'].update render(:partial => 'address_option')
  		    page["new_address_selected"].hide
  	    end
  	  end
    
    else
      @record = @customer
	    render :update => true, :layout => false do |page|
        # Please do not change the name of div 'new_address_selected'
		    page["new_address_selected"].show
		    page["new_address_selected"].update render(:partial => 'new_address')
		    #page['address_option'].update render(:partial => 'address_option')
		    page["address_selected"].hide
	    end
    end
	end

  # To save New Address of Customer. Added by SUHAS - October 1, 2008
	def new_customer_address
    @customer = Customer.find(params[:customer_id])
    @address = Address.new(params[:address])
    @address.customer_id = @customer.id
    @address.save
    render :update => true, :layout => false do |page|
      page["address_option"].update render(:partial => 'address_option')
    end
    #render :nothing => true
	end
	
	# To update Customers address - Added by SUHAS - October 2, 2008
	def update_customers_address
    @address = Address.find(params[:address_id])
    @customer = Customer.find(@address.customer_id)
    @address.update_attributes(params[:address])
    render :update => true, :layout => false do |page|
      page["address_option"].update render(:partial => 'address_option')
    end
    #render :nothing => true
	end

  def add_comment
    @record = Customer.find(params[:customer_id])
    @record.comments << Comment.new(:comment => params[:comment], :user => @current_user)
    render :update => true, :layout => false do |page|
      page.redirect_to view_customer_url(:value => @record.id)
    end
  end

  private
  
  def xul_headers
    response.headers["content-type"]="application/vnd.mozilla.xul+xml"
  end
	
end


