class Address < ActiveRecord::Base
  belongs_to :customer
  
  has_many :orders
  has_many :invoices
  
  allow_read( :all ){ |r| true }
  allow_write( :all ){ |r| true }
  
  def name 
    "#{self.first_name} #{self.last_name}"
  end
  
  def out_of_state?
    return true unless state == ApplicationController::TAX_STATE
  end
  
  def in_state?
    return true if state ==  ApplicationController::TAX_STATE
  end
  
end
