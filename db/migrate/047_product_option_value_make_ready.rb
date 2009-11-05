class ProductOptionValueMakeReady < ActiveRecord::Migration
  def self.up
    add_column "product_option_values", "makeready", :float
  end

  def self.down
    remove_column "product_option_values", "makeready"
  end
end
