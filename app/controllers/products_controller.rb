class ProductsController < ApplicationController
  
  layout 'customer'

  def index
    
  end
  
  
  
  def show1
  
  @hi = "its running"
  
  end
  
  def clubflyers
	  render :text => 'Please provide the text for this page'
  end 
  
  #this is original show method. i make it show1.
  
  def show
   
   /vishal running code... 
   @product_page = ProductPage.find_by_name(params[:name])
    @product = @product_page.products.first
    @product_options = {}
    @page_title = @product_page.title
    @meta_description = @product_page.meta_description
    @meta_keywords = @product_page.meta_keywords    /
    
    
    /code that i have written to enter d value in database.
    
    @product_page = ProductPage.new
    @product_page.name = params[:name]
    @product_page.title = params[:name]
    @product_page.meta_description = params[:name]
    @product_page.meta_keywords = params[:name]
    @product_page.save/
    
    @product_page = ProductPage.find_by_name(params[:name])
    @product = @product_page.products.first
    @product_options = {}
    @page_title = @product_page.title
    @meta_description = @product_page.meta_description
    @meta_keywords = @product_page.meta_keywords
   
    
    
    if request.post?
      handle_product_options_form
    end
  end


  def handle_product_options_form
    @quantity = params[:quantity].to_i
    
    @product = Product.find(params[:product_id]) if params[:product_id]
    @product_options = @product.valid_options( params[:product_options] ) if params[:product_options]
    
    logger.debug @product_options.to_yaml 
    
    @subtotal = @product.price_for( @quantity, @product_options )
    
    @mail_quant = 0
    if @product_options[:mailing] and @product_options[:mailing] != "None"
      params["mailing_quantity"] = (params["mailing_quantity"].to_i > params["quantity"].to_i)? params["quantity"] : params["mailing_quantity"]
      @mail_quant = params[:mailing_quantity].to_i if params[:mailing_quantity]
      @mailing_price = @product.mailing_price( @mail_quant, @product_options[:mailing] )
    else
      @mailing_price = 0
    end
    
    if request.xhr?
      render :update do | page |
        page['productForm'].update( render( :partial => "product_form" ))
      end
    end
    
    if params['addToCart.x']
      redirect_options_hash = { :controller => 'checkout', :action => 'add_to_cart', :product_id => @product.id, :quantity => @quantity, :return_to_url => params[:return_to_url] }
      @product_options.each{ | key, value | redirect_options_hash[ "product_options[#{key}]" ] = value }
      redirect_to( redirect_options_hash ) 
    end
  end
  
  def custom_quote
      if params[:email]=="" ||params[:name]=="" ||params[:phone]==""||params[:job_description]=="" ||params[:job_type]==""
      
      redirect_to :controller=>'pages',:action=>'custom_quote'
      flash[:notice]='<font color="#cc0000">Please fill the * Required Field </font>'
      else
    CustomerMail.deliver_custom_job(params)
     end
  end
  
  def custom_quote1
	  @variable = "hi"
  end
  
  
  def samples_request
    CustomerMail.deliver_samples_request(params)
  end
  
  
  def calculate_prices
    
  end

end
