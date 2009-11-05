class OrderAccountRep < ActiveRecord::Migration
  def self.up
    add_column "orders", "account_rep", :string, :limit => 40
  end

  def self.down
    remove_column "orders", "account_rep"
  end
end
