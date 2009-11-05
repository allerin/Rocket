class ApplicationController < ActionController::Base
  attr_reader :current_customer
  before_filter :assign_current_customer, :get_enabled_product_pages
  session :secret => "n0m4d", :name => 'nomad'
  
  TAX_STATE = 'CA'
  TAX_RATE = 0.085
  
  def home
    render 'products/home'
  end
  
  def assign_current_customer
    session[:customer] ||= 0
    @current_customer = Customer.find( :first, :conditions => ["id = ?", session[:customer]] )
    
    @cart = ( session[:cart] ||= Cart.new )
    @cart.customer = @current_customer
    
    ### Uncomment this to clear cart.
    #@cart = session[:cart] = Cart.new
    return true
  end
  
  def get_enabled_product_pages
    @enabled_product_pages = ProductPage.find_by_sql("SELECT * FROM `product_pages` where (SELECT COUNT(*) FROM products where products.product_page_id = product_pages.id and products.disabled IS NULL or products.disabled=0) > 0 ORDER BY product_pages.sort_order")
  end
  
  
  def title(title)
    @page_title = title
  end
  
  def signed_in?
    true if session[:customer].to_i > 0
  end
end