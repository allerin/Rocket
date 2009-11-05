class CreateCouponAssignments < ActiveRecord::Migration
  def self.up
    create_table :coupon_assignments do |t|
      t.column :coupon_id, :integer
      t.column :product_id, :integer
    end
  end

  def self.down
    drop_table :coupon_assignments
  end
end
