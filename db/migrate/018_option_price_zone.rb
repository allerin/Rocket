class OptionPriceZone < ActiveRecord::Migration
  def self.up
    create_table :option_price_zones do | popz |
      popz.column :max_quantity, :integer
      popz.column :setup_price, :float
      popz.column :unit_quantity, :integer
      popz.column :price_per_unit, :float
    end
    
    create_table( :option_price_zones_product_option_values, :id => false ) do | opzpov |
      opzpov.column :option_price_zone_id, :integer
      opzpov.column :product_option_value_id, :integer
    end
  end

  def self.down
    drop_table :option_price_zones
    drop_table :option_price_zones_product_option_values
  end
end
