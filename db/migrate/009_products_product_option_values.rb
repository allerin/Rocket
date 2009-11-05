class ProductsProductOptionValues < ActiveRecord::Migration
  def self.up
    create_table :products_product_option_values do |ppov|
      ppov.column :product_id, :integer
      ppov.column :product_option_value_id, :integer
    end
  end

  def self.down
    drop_table :products_product_option_values
  end
end
