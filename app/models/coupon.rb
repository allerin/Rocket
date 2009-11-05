class Coupon < ActiveRecord::Base
  has_many :coupon_assignments, :dependent => :destroy
  has_many :products, :through => :coupon_assignments
  
  allow_read(:all) { |r| true }
	allow_write(:all) { |r| r == :admin }
	
	def add_product(product)
	  unless self.coupon_assignments.find(:first, :conditions => ['coupon_assignments.product_id=?',product.id])
	    self.coupon_assignments << CouponAssignment.new(:product => product)
	  end
	end
	
end
