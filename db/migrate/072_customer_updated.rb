class CustomerUpdated < ActiveRecord::Migration
  def self.up
    add_column "customers", "confirm_updated", :boolean
  end

  def self.down
    remove_column "customers", "confirm_updated"
  end
end
