class PackageMoreAttributes < ActiveRecord::Migration
  def self.up
    add_column "packages", "shortname", :string
    add_column "packages", "subtitle", :string
    add_column "package_item_option_values", "default", :integer, :limit => 1
  end

  def self.down
    remove_column "packages", "shortname"
    remove_column "packages", "subtitle"
    remove_column "package_item_option_values", "default"
  end
end
