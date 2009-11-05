class DesignOrderCreatedAt < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "created_at", :datetime
    add_column "orders", "created_at", :datetime
  end

  def self.down
    remove_column "design_orders", "created_at"
    remove_column "orders", "created_at"
  end
end
