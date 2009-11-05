class CartPackageItem
  include CartShippable
  include CartPayable
  
  attr_accessor :package, :package_item, :option_values, :quantity, :versions, :version_names, :comments, :mail_house, :custom_name
  attr_writer   :reseller_id
  attr_reader   :coupon
    
  def initialize(cart_package, package_item)
    @package = cart_package
    @package_item = package_item
    @option_values = product_options_with_default_values
    @quantity = package_item.default_quantity
    @versions = 1
    @version_names = []
    @reseller_id = nil
    @mail_house = false
    @comments = nil
    @coupon = nil
    @custom_name = nil
  end
  
  def method_missing(symbol, *args)
    @package_item.send(symbol, *args)
  end
  
  def id
    package_item.id
  end
  
  def base_price
    package_item.price_for((quantity.to_i * versions.to_i), option_values.merge(package.option_values)) + ((versions.to_i - 1).to_f * (version_surcharge || 0))
  end
  
  def discount
    if coupon
      base_price * coupon.discount.to_f
    else
      0.0
    end
  end
    
  def price 
    base_price - discount
  end
  
  def tax
    if taxable?
      return (price * ApplicationController::TAX_RATE)
    else
      return 0.0
    end
  end
  
  def taxable?
    return false if reseller_id and not reseller_id.empty?
    return false if mail_house
    return false unless ((package.shipping_address and package.shipping_address.in_state?) or 
                        (package.cart.customer and package.cart.customer.billing_address and package.cart.customer.billing_address.in_state?))
    
    return true
  end
  
  def total_price
    price.to_f + tax.to_f + shipping_price.to_f
  end
  
  def shipping_quantity
    quantity
  end
  
  def shipping_price
    return ((( shipping_method.cost or 0.0 ) rescue 0.0) * (versions || 1).to_i)
  end
  
  def raw_options
    product_options.inject({}) do |hash, option|
      hash[option] = option_values[option]
      hash
    end
  end
  
  def soft_options
    raw_options.inject({}) do |hash, option_value|
      hash[option_value.first.title] = option_value.last.label
      hash
    end
  end
  
  def customer
    package.cart.customer
  end
  
  def cart_index
    self.package.cart.packages.collect(&:package_items).flatten.index(self)
  end
  
  
  def to_order(order = Order.new, options = {})
    order.quantity = self.quantity
    order.address_id = self.shipping_address_id
    order.shipping_method_id = self.shipping_method_id
    order.reseller_id = self.reseller_id
    order.mail_house = self.mail_house
    order.customer_comments = self.comments
    order.coupon_code = self.coupon.code if self.coupon
    
    unless options[:zero_prices]
      order.price = self.price
      order.tax = self.tax
      order.total = self.total_price
      order.shipping_price = self.shipping_price
    end
  
    order.product = self.product
    order.product_sku = self.product.sku
    order.product_height = self.product.height
    order.product_width = self.product.width
    order.product_title = self.product.title
    order.product_code = self.product.product_code
    order.product_setup_price = self.product.setup_price
    order.product_markup = self.product.markup( self.quantity )
    order.product_weight_per_unit = self.product.weight_per_unit
    order.product_weight_unit_size = self.product.weight_unit_size
    order.product_turnaround_offset = self.product.turnaround_offset
    
    order.product_option_values.clear
    all_option_values = option_values.merge(package.option_values)
    merged_options = (self.package.product_options + self.product_options).uniq
    merged_options.each do | option |
      order.product_option_values << OrderProductOptionValue.new_from_product_option_value( all_option_values[option] )
    end
    order.payments << payment.clone if payment
    order
  end
  
  def to_orders(invoice, options = {})
    (1..(self.versions || 1).to_i).collect do |v| 
      order = self.to_order(Order.new(:invoice => invoice), :zero_prices => (true if v > 1))
      order.custom_name = "#{v} of #{(self.versions || 1)}" if self.versions and self.versions.to_i > 1
      order
    end
  end
  
  
  def cart
    package.cart
  end
  
  def reseller_id
    @reseller_id || (cart.customer.reseller_id if cart.customer)
  end
  
  def apply_coupon(coupon)
    product.reload
    if product.coupon_applicable?(coupon)
      @coupon = coupon
    end
  end
  
end