class MoreProductsProductOptionValues < ActiveRecord::Migration
  def self.up
    add_column :products_product_option_values, :sort_order, :integer
  end

  def self.down
    remove_column :products_product_option_values, :sort_order
  end
end
