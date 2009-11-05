class ProductPageNavbarTitle < ActiveRecord::Migration
  def self.up
    add_column "product_pages", "navbar_title", :string
  end

  def self.down
    remove_column "product_pages", "navbar_title"
  end
end
