class OrderResller < ActiveRecord::Migration
  def self.up
    add_column "orders", "reseller_id", :string, :limit => 20
    add_column "orders", "mail_house", :string
  end

  def self.down
    remove_column "orders", "reseller_id"
    remove_column "orders", "mail_house"
  end
end
