class CartPackage < CartItem
  
  attr_accessor :package, :package_items, :option_values
  
  def initialize( parent_cart, package )
    super(parent_cart)
    @package = package
    @package_items = package.package_items.collect { |item| CartPackageItem.new(self, item) }
    @option_values = product_options_with_default_values
  end
  
  def id
    package.id
  end

  def method_missing(symbol, *args)
    @package.send(symbol, *args)
  end
  
  def price
    package_items.inject(0) { |price, item| price += item.price }
  end
  
  def tax
    package_items.inject(0) { |tax, item| tax += item.tax }
  end
  
  def shipping_price
    package_items.inject(0) { |tax, item| tax += item.shipping_price }
  end
  
  def cart_index
    return self.cart.packages.index( self )
  end
  
  def total_price
    price + tax
  end
  
end