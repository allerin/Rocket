class ProductDisabled < ActiveRecord::Migration
  def self.up
    add_column "products", "disabled", :boolean
    add_column "product_pages", "sort_order", :integer
  end

  def self.down
    remove_column "products", "disabled"
    remove_column "product_pages", "sort_order"
  end
end
