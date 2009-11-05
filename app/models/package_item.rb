class PackageItem < ActiveRecord::Base
  has_many :package_item_option_values, :dependent => true
  belongs_to :product
  belongs_to :package
  
  allow_read(:all){ |r| true }
	allow_write(:all){ |r| r == :admin }
  
  def options
    if self.package_item_option_values == @override_povs_last_time
      return @override_product_options
    else
      @override_povs_last_time = self.package_item_option_values
      @override_product_options = ProductOption.find( :all,
                                             :select => "DISTINCT product_options.*",
                                             :joins => "LEFT JOIN product_option_values ON product_options.id=product_option_values.product_option_id " + 
                                                       "LEFT JOIN package_item_option_values ON package_item_option_values.product_option_value_id=product_option_values.id",
                                              :conditions => ['package_item_option_values.package_item_id = ?', self.id] )
    end
  end
  
  
  def product_option_values_for_product_option(option)
    if @blah_piovs_last_time and self.package_item_option_values == @blah_piovs_last_time[option]
      overrides = @blah_overrides_last_time[option]
    else
      overrides = ProductOptionValue.find(:all,
                                          :select => "product_option_values.*",
                                          :joins => "LEFT JOIN package_item_option_values ON package_item_option_values.product_option_value_id=product_option_values.id",
                                          :conditions => ['package_item_option_values.package_item_id = ? AND product_option_values.product_option_id = ?', self.id, option.id ] )
      @blah_overrides_last_time ||= {}
      @blah_overrides_last_time[option] = overrides
      @blah_piovs_last_time ||= {}
      @blah_piovs_last_time[option] = self.package_item_option_values
    end
                                        
    return (overrides.empty? ? self.product.product_option_values_for_product_option(option) : overrides)
  end
  
  def default_option_value(option)
    override = ProductOptionValue.find(:first,
                                      :select => "product_option_values.*",
                                      :joins => "LEFT JOIN package_item_option_values ON package_item_option_values.product_option_value_id=product_option_values.id",
                                      :conditions => ['package_item_option_values.package_item_id = ? AND product_option_values.product_option_id = ?', self.id, option.id ],                 :order => "(package_item_option_values.default = 1) DESC" )
                                      
    
    return (override or self.product.default_product_option_value(option))
  end
  
  def product_options_with_default_values
    product_options.inject({}) { |product_options, option| product_options[option] = default_option_value(option); product_options }
  end
  
  def visible_options
    self.product_options.collect { |option|
      option if self.product_option_values_for_product_option(option).length > 1 }.compact
  end
  
  def hidden_options
    self.product_options.collect { |option|
      option if self.product_option_values_for_product_option(option).length == 1 }.compact
  end
  
  
  def product_options
    overrides = self.options.inject({}) { |hash, option| hash[option.id] = option; hash }
    regulars = self.product.product_options.inject({}) { |hash, option| hash[option.id] = option; hash }
    merged = regulars.merge(overrides)
    
    self.package.product_options.each { |option| merged.delete(option.id) }
    
    return merged.values
  end
  
  def price_for(quantity, opts = {}, validate_options = true)
    product.price_for(quantity, opts, false)
  end
  
  
  
  def validate_ops(soft_options)
    
  end
  
  def title
    if custom_name.nil? or custom_name.empty?
      return product.title
    else
      return custom_name
    end
  end
  
  def quantity_options
    options = product.quantity_options
    options = options.delete_if { |q| q < min_quantity } if min_quantity and min_quantity > 0
    options = options.delete_if { |q| q > max_quantity } if max_quantity and max_quantity > 0
    return options
  end
  
end
