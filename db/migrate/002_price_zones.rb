class PriceZones < ActiveRecord::Migration
  def self.up
    create_table :price_zones do |pz|
      pz.column :product_id, :integer
      pz.column :min_quantity, :integer
      pz.column :markup, :float
    end
    
    add_index :price_zones, :product_id
    add_index :price_zones, :min_quantity
  end

  def self.down
    drop_table :price_zones
  end
end
