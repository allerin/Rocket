class PackageOptionValueDefault < ActiveRecord::Migration
  def self.up
    add_column "package_option_values", "default", :boolean
  end

  def self.down
    remove_column "package_option_values", "default"
  end
end
