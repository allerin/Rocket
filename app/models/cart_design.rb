class CartDesign < CartItem
  
  attr_accessor :job_number, :for_cart_item, :copy, :comments
  attr_writer :for_product_id
  
  def initialize( cart )
    super
    @job_number = nil
    @for_product_id = nil
    @for_cart_item = nil
    @for_product = nil
    @copy = nil
    @comments = nil
  end
  
  def cart_index
    return self.cart.design_jobs.index( self )
  end
  
  def for_product_id
    if @for_cart_item
      return @for_cart_item.product_id
    else
      return @for_product_id
    end
  end  
  
  def for_product
    if @for_product and for_product_id and @for_product.id == for_product_id
      return @for_product
    elsif for_product_id
      return @for_product = Product.find( :first, :conditions => ["id = ?", for_product_id] )
    end
  end
  
  def product
    for_product
  end
  
  def design_options
    raw_options = {}
    soft_options.each do | option_label, value_label |
      option = DesignOption.find(:first, :conditions => "label = '#{option_label}'")
      value = option.design_option_values.find(:first, :conditions => "label = '#{value_label}'")
      raw_options[ option ] = value if option and value
    end
    return raw_options
  end
  
  def reorder?
    return true if job_number
  end
  
  def total_price
    return base_price + options_price ## + tax
  end
  
  def subtotal
    return base_price + options_price
  end
  
  def base_price
    cost = 0.0
    if reorder?
      cost += 10
    else
      if soft_options[:sides]
        if soft_options[:sides].to_i == 1 and product.one_sided_layout_price.to_f > 0
          cost += product.one_sided_layout_price.to_f
        else
          cost += product.two_sided_layout_price.to_f
        end
      else
        if product.one_sided_layout_price and product.one_sided_layout_price > 0
          cost += product.one_sided_layout_price
        elsif product.two_sided_layout_price and product.two_sided_layout_price > 0
          cost += product.two_sided_layout_price
        else
          #raise "There is no layout pricing for this product (id = #{product.id})"
        end
      end
    end
    return cost
  end
  
  def options_price
    cost = 0.0
    design_options.each do | option, value |
      cost += value.setup_price if value.setup_price
    end
    return cost
  end
  
  def to_order(design_order = DesignOrder.new, options = {})
    design_order.custom_name =  self.custom_name
    design_order.address_id ||= self.shipping_address_id
    design_order.shipping_method_id = self.shipping_method_id
    design_order.order_id = self.for_cart_item.order_id if self.for_cart_item
    design_order.product_id = self.for_product_id
    design_order.copy = self.copy
    design_order.comments = self.comments
    
    self.job_number = design_order.parent.full_job_number if design_order.parent
    if self.reorder? and old_job = DesignOrder.find_by_full_job_number(self.job_number)
      design_order.parent_id = old_job.id
    end
    
    design_order.design_option_values.clear
    self.design_options.each do | option, value |
      design_order.design_option_values << DesignOrderOptionValue.new_from_design_option_value( value )
    end
    
    design_order.price = self.subtotal
    design_order.total = self.total_price
    
    design_order.payments << payment if payment
    
    return design_order
  end
  
  

end