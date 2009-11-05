class CustomerAccountRep < ActiveRecord::Migration
  def self.up
    add_column "customers", "account_rep", :string, :limit => 40
  end

  def self.down
    remove_column "customers", "account_rep"
  end
end
