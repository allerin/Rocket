class DesignOrderStatus < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "status", :string, :limit => 40
  end

  def self.down
    remove_column "design_orders", "status"
  end
end
