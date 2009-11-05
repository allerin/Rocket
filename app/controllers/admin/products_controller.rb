class Admin::ProductsController < Admin::AdminController
  
  layout 'main'
  
  before_filter :signin_required
  
  def show

    @views = {'list' => 24, 'detail' => 1}
    
		@view = if @views.keys.include?(params[:view])
		          session[:view] = params[:view]
		        elsif @views.keys.include?(session[:view])
		          session[:view]
		        else
		          @views.keys.first
		        end
		
		per_page = @views[@view]
		
		key, value =  if params[:key]
		                session[:products_page], session[:product_id] = nil  
		                session[:products_key], session[:products_value] = params[:key], params[:value]
		              else
		                [ session[:products_key], session[:products_value] ]
		              end
		              
		product_id =  if params[:id]
		                session[:product_id] = params[:id]
		              else
		                session[:product_id]
		              end
		
		sort =  'products.product_page_id, products.title'
		
		if params[:page]
			session[:products_page] = params[:page]
		elsif session[:products_page]
			params[:page] = session[:products_page]
		end
			
		search_conditions = if params[:all]
                          session[:quicksearch], session[:products_page], session[:product_id] = nil
  	                      session[:products_key], session[:products_value] = nil
  	                      "1"
                    		elsif params[:next]
                    		  ["products.id > ?"]
                    		elsif product_id and @view == 'detail'
                          ["products.id = ?", product_id]  
                    		elsif key and value
                      		["`#{key}` = ?", value] 
                    		end

	  
		pager_params = {
		  :order => sort,
		  :per_page => per_page
		}
		
		pager_params[:conditions] = search_conditions if search_conditions
		
 		@pages, @records = paginate :products, pager_params

    @product_pages = ProductPage.find(:all)

    if product = @records[0] 
      next_conditions = [ "products.product_page_id = #{product.product_page_id || 'NULL'} AND products.title > '#{product.title}'",
                          "products.product_page_id = #{product.product_page_id || 'NULL'} AND products.title = '#{product.title}' AND products.id > #{product.id}",
                          "products.product_page_id > #{product.product_page_id || 'NULL'}" ].collect { |c| "(" + c + ")" }
                          
      previous_conditions = [ "products.product_page_id = #{product.product_page_id || 'NULL'} AND products.title < '#{product.title}'",
                              "products.product_page_id = #{product.product_page_id || 'NULL'} AND products.title = '#{product.title}' AND products.id < #{product.id}",
                              "products.product_page_id < #{product.product_page_id || 'NULL'}" ].collect { |c| "(" + c + ")" }
      @next_record = Product.find(:first, 
                                  :conditions => next_conditions.join(" OR "),
                                  :order => next_conditions.collect.collect { |c| c + " DESC" }.join(",") +
                                  ", products.product_page_id, products.title, products.id" )
      @previous_record = Product.find(:first, 
                                      :conditions => previous_conditions.join(" OR "),
                                      :order => previous_conditions.collect.collect { |c| c + " DESC" }.join(",") +
                                      ", products.product_page_id DESC, products.title DESC, products.id DESC" )                                          
    end

		@loading = ""
		@complete = ""
		if request.xhr?
			render :partial => 'show' 
		end

  end
  
  def edit    
    if params[:id]
      @product = Product.find(params[:id])
    else
      @product = Product.new
      session[:product_id] = params[:id] = nil
    end
    
    @product.title = params[:product][:title]
    @product.sku = params[:product][:sku]
    @product.product_code = params[:product][:product_code]
    @product.height = params[:product][:height]
    @product.width = params[:product][:width]
    @product.clarifying_info = params[:product][:clarifying_info]
    @product.setup_price = params[:product][:setup_price]
    @product.product_page_id = params[:product][:product_page_id]
    @product.cart_image = params[:product][:cart_image]
    @product.one_sided_layout_price = params[:product][:one_sided_layout_price]
    @product.two_sided_layout_price = params[:product][:two_sided_layout_price]
    @product.one_sided_design_price = params[:product][:one_sided_design_price]
    @product.two_sided_design_price = params[:product][:two_sided_design_price]
    @product.weight_per_unit = params[:product][:weight_per_unit]
    @product.weight_unit_size = params[:product][:weight_unit_size] 
    @product.default_quantity = params[:product][:default_quantity]
    @product.disabled = params[:product][:disabled]
    @product.sort_order = params[:product][:sort_order]
    @product.turnaround_offset = params[:product][:turnaround_offset]   
        
    if params[:price_zones]
      params[:price_zones].each do | key, value |
        if value['max_quantity'].empty? or value['markup'].empty? or value['quantity_increment'].empty?
          PriceZone.delete(key)
        else
          pz = PriceZone.find(key)
          pz.max_quantity = value['max_quantity']
          pz.markup = value['markup']
          pz.quantity_increment = value['quantity_increment']
          pz.save 
        end
      end
    end

    if params[:new_price_zone] and params[:new_price_zone][:max_quantity] and params[:new_price_zone][:markup] and params[:new_price_zone][:quantity_increment]
      if params[:new_price_zone][:max_quantity].to_i > 0 and params[:new_price_zone][:markup].to_f > 0 and params[:new_price_zone][:quantity_increment].to_i > 0
        pz = PriceZone.new
        pz.max_quantity = params[:new_price_zone][:max_quantity]
        pz.markup = params[:new_price_zone][:markup] 
        pz.quantity_increment = params[:new_price_zone][:quantity_increment]
        @product.price_zones << pz
      end
    end
    
    if params[:product_option_values]
      @product.product_option_values.clear
      params[:product_option_values].each do | key, value |
        pov = ProductOptionValue.find(key)
        
        is_default = false 
        
        if params[:product_option_value_defaults] and params[:product_option_value_defaults][pov.product_option_id.to_sym]
          is_default = ( params[:product_option_value_defaults][pov.product_option_id.to_sym].to_s == pov.id.to_s)
        end        

        #if params[:makereadies] and params[:makereadies][pov.id.to_s]
        #  makeready = (pov.make_readies.find(:first, 
         #                                   :conditions => "product_id = #{@product.id}") or MakeReady.new(:product_id => @product.id, :product_option_value_id => pov.id))
          #makeready.price = params[:makereadies][pov.id.to_s]
          #makeready.save
        #end
        
        ppov = ProductsProductOptionValue.new
        ppov.default = is_default
        ppov.product_option_value = pov
        
        @product.products_product_option_values << ppov
      end
      
      #if params[:product_option_value_defaults]
      #  @product.product_option_values.each do | pov |
      #    pov.default = true if params[:product_option_value_defaults][pov.product_option_id.to_sym] == pov.id.to_s
      #  end
      #end
    end
    
    if params[:makereadies]
      params[:makereadies].each do | pov_id, value |
        makeready = (MakeReady.find( :first, 
                                    :conditions => ["product_id=? AND product_option_value_id=?", @product.id, pov_id]) or MakeReady.new(:product_id => @product.id, :product_option_value_id => pov_id))
        makeready.price = value
        makeready.save
      end
    end
    
    if params[:add_product_option] and params[:new_product_option] != "none"
      @product.product_option_values << ProductOptionValue.find(:all, :conditions => "product_option_id=#{params[:new_product_option]}")
    end
    
    @product.save
    
    params[:view] = 'detail'
    if request.xhr?
      params[:id] = @product.id
      show
    else
      redirect_to :action => 'show', :view => 'detail', :id => @product.id
    end
    
  end
  
  def new
  
    @pages = []
    @records = [ Product.new( :title => "Untitled Product" ) ]
    @product_pages = ProductPage.find(:all)
    @view = 'detail'
    
    if request.xhr?
      render :partial => "show"
    else
      render :action => 'show'
    end
    
  end
  
  def destroy
    Product.destroy(params[:id])
    show
  end
  
  def autocomplete_for_sku
    @products = Product.find(:all, :conditions => ["sku LIKE ?",  params[:product_sku] + '%'], :order => 'sku ASC', :limit => 10)
    render :partial => "autocomplete_skus"
  end
  
  # To find out the SKU of the selected product from 'products' table - Sept 18, 2008
  def find_product_sku
    @product = Product.find(params[:id])
    #render :partial => "find_product_sku"
    
    render :update => true, :layout => false do |page|
      page["product_sku12"].replace_html render(:partial => "find_product_sku")
    end
  end
  
  
end
