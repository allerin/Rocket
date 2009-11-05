class PackageItemDefaultQuantity < ActiveRecord::Migration
  def self.up
    add_column "package_items", "default_quantity", :integer
  end

  def self.down
    remove_column "package_items", "default_quantity"
  end
end
