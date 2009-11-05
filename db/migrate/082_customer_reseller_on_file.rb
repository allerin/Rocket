class CustomerResellerOnFile < ActiveRecord::Migration
  def self.up
    add_column "customers", "reseller_on_file", :boolean
  end

  def self.down
    remove_column "customers", "reseller_on_file"
  end
end
