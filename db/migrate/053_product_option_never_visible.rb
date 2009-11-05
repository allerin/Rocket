class ProductOptionNeverVisible < ActiveRecord::Migration
  def self.up
    add_column "product_options", "never_visible", :boolean
  end

  def self.down
    remove_column "product_options", "never_visible"
  end
end
