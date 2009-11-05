class ProductPageTooltip < ActiveRecord::Migration
  def self.up
    add_column "products", "size_tooltip", :string
  end

  def self.down
    remove_column "product_pages", "size_tooltip"
  end
end
