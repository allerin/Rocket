class ProductOptionAlwaysShowInForm < ActiveRecord::Migration
  def self.up
    add_column "product_options", "always_visible", :boolean
  end

  def self.down
    remove_column "product_options", "always_visible"
  end
end
