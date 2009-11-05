class ShippingMethod < ActiveRecord::Base
  
  attr_accessor :cost
  
  def initialize
    super
    @cost = 0.0
  end
  
end
