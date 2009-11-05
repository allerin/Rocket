class Postage < ActiveRecord::Base
  belongs_to :products
  belongs_to :product_option_value, :foreign_key => 'mailing_option_value_id'
end
