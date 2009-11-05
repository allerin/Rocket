class PackageItemMinQuantity < ActiveRecord::Migration
  def self.up
    add_column "package_items", "min_quantity", :integer
  end

  def self.down
    remove_column "package_items", "min_quantity"
  end
end
