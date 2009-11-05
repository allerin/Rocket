#this is a join model that says what ProductOptionValues should be available to a packaged Product, overriding the Product's normal ProductOptionValues. 

class PackageItemOptionValue < ActiveRecord::Base
  belongs_to :package_item
  belongs_to :product_option_value
  
  allow_read(:all){ |r| true }
	allow_write(:all){ |r| r == :admin }
end
