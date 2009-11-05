class PackageItemVersions < ActiveRecord::Migration
  def self.up
    add_column "package_items", "max_versions", :integer
  end

  def self.down
    remove_column "package_items", "max_versions"
  end
end
