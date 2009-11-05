class OrderCouponCode < ActiveRecord::Migration
  def self.up
    add_column "orders", "coupon_code", :string, :limit => 20
  end

  def self.down
    remove_column "orders", "coupon_code"
  end
end
