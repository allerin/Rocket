class OrderReprint < ActiveRecord::Migration
  def self.up
    add_column "orders", "reprint", :boolean
  end

  def self.down
    remove_column "orders", "reprint"
  end
end
