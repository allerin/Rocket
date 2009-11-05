class NoIDsOnUnionTablesPlease < ActiveRecord::Migration
  def self.up
    remove_column :products_product_option_values, :id
  end

  def self.down
     add_column :products_product_option_values, :id, :integer
  end
end
