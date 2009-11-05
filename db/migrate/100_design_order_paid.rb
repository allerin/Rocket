class DesignOrderPaid < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "paid_at", :datetime
    add_column "design_orders", "commission_paid_at", :datetime
  end

  def self.down
    remove_column "design_orders", "paid_at"
    remove_column "design_orders", "commission_paid_at"
  end
end
