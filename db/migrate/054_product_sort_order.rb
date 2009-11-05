class ProductSortOrder < ActiveRecord::Migration
  def self.up
    add_column "products", "sort_order", :integer
  end

  def self.down
    remove_column "products", "sort_order"
  end
end
