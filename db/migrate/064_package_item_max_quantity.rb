class PackageItemMaxQuantity < ActiveRecord::Migration
  def self.up
    add_column "package_items", "max_quantity", :integer
  end

  def self.down
    remove_column "package_items", "max_quantity"
  end
end
