class ExtraCharge < ActiveRecord::Base
  belongs_to :order
  belongs_to :design_order
  
end
