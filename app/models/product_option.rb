# (c) Copyright 2005 Trigger Consulting. All Rights Reserved. 

# Class for Product options. These define the billable
# variations a product can have.
#
# _Associations_:
# has_and_belongs_to_many :: Product
# has_many:: ProductOptionValue
class ProductOption < ActiveRecord::Base
	has_and_belongs_to_many :products
	has_many :product_option_values
	belongs_to :product_option_value
end
