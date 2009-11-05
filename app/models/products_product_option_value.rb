class ProductsProductOptionValue < ActiveRecord::Base
  belongs_to :product_option_value
  belongs_to :product
end
