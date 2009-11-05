class WeighToOptionValues < ActiveRecord::Migration
  def self.up
    add_column "product_option_values", "weight_multiplier", :float
  end

  def self.down
    remove_column "product_option_values", "weight_multiplier"
  end
end
