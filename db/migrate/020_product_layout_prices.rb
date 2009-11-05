class ProductLayoutPrices < ActiveRecord::Migration
  def self.up
    add_column "products", "one_sided_layout_price", :float
    add_column "products", "two_sided_layout_price", :float
  end

  def self.down
    remove_column "products", "one_sided_layout_price"
    remove_column "products", "two_sided_layout_price"
  end
end
