class Package < ActiveRecord::Base
  has_many :package_items
  has_many :package_option_values, :dependent => :delete_all
  
  allow_read(:all) { |r| true }
	allow_write(:all) { |r| r == :admin }
  
  def product_options
    #returns the ProductOptions that are overridden by this package
	  return [] if new_record?
  	ProductOption.find( :all,
                        :select => 'DISTINCT product_options.*',
                        :joins => ' LEFT JOIN product_option_values on product_options.id = product_option_values.product_option_id LEFT JOIN package_option_values ON product_option_values.id=package_option_values.product_option_value_id ',
                        :conditions => "package_option_values.package_id=#{self.id}",
                        :order => 'product_options.id ASC')
  end
  
  def product_option_values_for_product_option(option)
    ProductOptionValue.find(:all,
                            :select => "product_option_values.*",
                            :joins => "LEFT JOIN package_option_values ON package_option_values.product_option_value_id=product_option_values.id",
                            :conditions => ['package_option_values.package_id = ? AND product_option_values.product_option_id = ?', 
                                            self.id, option.id] )
  end
  
  def default_option_value(option)
    ProductOptionValue.find(:first,
                            :select => "product_option_values.*",
                            :joins => "LEFT JOIN package_option_values ON package_option_values.product_option_value_id=product_option_values.id",
                            :conditions => ['package_option_values.package_id = ? AND product_option_values.product_option_id = ?', 
                                            self.id, option.id],
                            :order => "(package_option_values.default = 1) DESC" )
                              
  end
  
  def product_options_with_default_values
    product_options.inject({}) { |product_options, option| product_options[option] = default_option_value(option); product_options }
  end
  
  
end
