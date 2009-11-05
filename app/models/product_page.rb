class ProductPage < ActiveRecord::Base
  has_many :products, :order => "products.sort_order"
    
    
  def enabled_products
    self.products.find(:all, :conditions => "products.disabled IS NULL or products.disabled=0")
  end
end
