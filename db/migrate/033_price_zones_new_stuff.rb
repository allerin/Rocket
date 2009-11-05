class PriceZonesNewStuff < ActiveRecord::Migration
  def self.up
    rename_column "price_zones", "min_quantity", "max_quantity"
    add_column "price_zones", "quantity_increment", :integer
    add_index :price_zones, [:product_id, :max_quantity], :name => "product_quantities"
  end

  def self.down
    rename_column "price_zones", "max_quantity", "min_quantity"
    remove_column "price_zones", "quantity_increment"
    remove_index :price_zones, :name => :product_quantities
  end
end
