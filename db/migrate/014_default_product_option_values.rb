class DefaultProductOptionValues < ActiveRecord::Migration
  def self.up
    add_column :products_product_option_values, :default, :boolean
  end

  def self.down
    remove_column :products_product_option_values, :default
  end
end
