class CartProduct < CartItem
    
  attr_accessor :quantity, :order_id, :shipping_methods, :extra_charges, :comments, :mail_house
  attr_writer :mailing_quantity, :reseller_id
  attr_reader :product_id
  
  def initialize( parent_cart )
    super
    @product_id = 0
    @product = nil
    @quantity = 0
    @mailing_quantity = 0
    @order_id = nil
    @shipping_methods = []
    @extra_charges = []
    @reseller_id = nil
    @mail_house = nil
    @comments = nil
  end
  
  def product_id=(id)
    @product_id = id.to_i
    @product = Product.find(id)
  end
  def cart_index
    return self.cart.products.index( self )
  end
  
  def reseller_id
    @reseller_id || (cart.customer.reseller_id if cart.customer)
  end
  
  def mailing_quantity
    if soft_options[:mailing].nil? or soft_options[:mailing].downcase == "none"
      return 0
    else
      @mailing_quantity = @quantity if @mailing_quantity > @quantity
      return @mailing_quantity
    end
  end
  
  def shipping_quantity
    actual = actual_shipping_quantity
    return 0 if actual == 0
    product.quantity_options.sort{ |a,b| a <=> b }.find{ |q| q >= actual }
  end
  
  def actual_shipping_quantity
    if shipping_address and shipping_address_id
      return quantity - mailing_quantity
    else
      return 0
    end
  end
  
  def taxable_quantity
    leftover = quantity - mailing_quantity 
    product.next_quantity_step(leftover)
  end
  
  def taxable_ratio
    taxable_quantity.to_f / quantity.to_f 
  end
  
  def product
    if @product and @product.id == @product_id
      return @product
    elsif @product_id
      return @product = Product.find(:first, :conditions => ["id = ?", @product_id])
    end
  end

  def product=(p)
    @product = p
    @product_id = p.id
  end
  
  def product_options
    self.product.soft_options_set_to_raw_set( self.soft_options )
  end
  
  def discount
    if coupon
      base_price * coupon.discount.to_f
    else
      0.0
    end
  end

  def base_price
    product.price_for( quantity, soft_options )
  end
  
  def price
    base_price - discount
  end
  
  def mailing_price
    product.mailing_price( mailing_quantity, soft_options[:mailing] )
  end
  
  def postage_price
    product.postage_price( mailing_quantity, soft_options[:mailing] )
  end
  
  def tax
    if taxable?
      return (price * taxable_ratio * ApplicationController::TAX_RATE)
    else
      return 0
    end
  end
    
  def taxable?
    return false if reseller_id and not reseller_id.empty?
    return false if mail_house
    return false unless ((shipping_address and shipping_address.in_state?) or 
                        (@cart.customer and @cart.customer.billing_address and @cart.customer.billing_address.in_state?))
    return false if taxable_quantity == 0
    
    return true
  end
  
  def extra_charges_price
    self.extra_charges.inject(0.0) do |t, charge| 
      t += charge.price.to_f
    end
  end

  def total_price
    price + 
      mailing_price + 
        shipping_price +
          postage_price + 
            tax +
              extra_charges_price
  end
  
  def boxes    
    return product.boxes_for( shipping_quantity, soft_options )    
  end
  
  def get_ups_rates
    self.shipping_methods = ShippingMethod.find(:all, :conditions => "ups_service_code IS NOT NULL")
    
    if boxes.length > 0 
      ups = UPS::RatesAndServicesRequest.new
      ups.build_rate_request( boxes, shipping_address )
      ups.submit_request
      ups_rated_shipments = ups.rated_shipments.clone  
      
      self.shipping_methods.each do | method |
        if rate = ups_rated_shipments.find{ |s| s.code.to_s == method.ups_service_code.to_s }
          method.cost = rate.total_charges
        end
      end
    end
  end
  
  def shipping_price
    return ( shipping_method.cost or 0.0 ) rescue 0.0
  end
    
  ## Note that if you want to ensure your methods are fresh, you should call shipping_methods first.
  def shipping_method
    shipping_methods.find{ |m| m.id == shipping_method_id.to_i } if shipping_method_id
  end

  def to_order(order = Order.new, options = {})
    order.quantity = self.quantity
    order.address_id = self.shipping_address_id
    order.shipping_method_id = self.shipping_method_id
    order.custom_name = self.custom_name
    order.price = self.price
    order.tax = self.tax
    order.total = self.total_price
    order.shipping_price = self.shipping_price
    order.shipping_method_id = self.shipping_method_id
    order.reseller_id = self.reseller_id
    order.mail_house = self.mail_house
    order.customer_comments = self.comments
    order.coupon_code = self.coupon.code if self.coupon
    
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
    order.mailing_quantity = self.mailing_quantity
    order.mailing_price = self.product.mailing_price( self.mailing_quantity )
    order.postage_price = self.postage_price
    order.product_turnaround_offset = self.product.turnaround_offset
    
    order.product_option_values.clear
    
    self.product_options.each do | option, value |
      order.product_option_values << OrderProductOptionValue.new_from_product_option_value( value )
    end
    
    order.extra_charges.clear
    
    self.extra_charges.each do |charge|
      order.extra_charges << charge
    end
    
    order.payments << payment if payment
    order
  end
  
  def apply_coupon(coupon)
    product.reload
    if product.coupon_applicable?(coupon)
      @coupon = coupon
    end
  end
end