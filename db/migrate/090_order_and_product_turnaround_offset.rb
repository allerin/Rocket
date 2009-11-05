class OrderAndProductTurnaroundOffset < ActiveRecord::Migration
  def self.up
    add_column "products", "turnaround_offset", :integer, :default => 0
    add_column "orders", "product_turnaround_offset", :integer, :default => 0
  end

  def self.down
    remove_column "products", "turnaround_offset"
    remove_column "orders", "product_turnaround_offset"
  end
end
