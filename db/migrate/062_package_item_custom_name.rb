class PackageItemCustomName < ActiveRecord::Migration
  def self.up
    add_column "package_items", "custom_name", :string
  end

  def self.down
    remove_column "package_items", "custom_name"
  end
end
