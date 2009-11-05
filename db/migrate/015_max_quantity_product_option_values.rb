class MaxQuantityProductOptionValues < ActiveRecord::Migration
  def self.up
    add_column :products_product_option_values, :max_quantity, :integer
  end

  def self.down
    remove_column :products_product_option_values, :max_quantity
  end
end
