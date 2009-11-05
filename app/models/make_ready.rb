class MakeReady < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_option_value
  
end
