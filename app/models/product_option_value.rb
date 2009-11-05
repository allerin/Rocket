# (c) Copyright 2005 Trigger Consulting. All Rights Reserved. 

# Class defining the possible values for ProductOption entries.
#
# _Associations_:
# belongs_to:: ProductOption
class ProductOptionValue < ActiveRecord::Base
	belongs_to :product_option
	has_and_belongs_to_many :orders
	has_and_belongs_to_many :option_price_zones
	has_many :make_readies
end
