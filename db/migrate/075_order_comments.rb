class OrderComments < ActiveRecord::Migration
  def self.up
    add_column "orders", "customer_comments", :string
  end

  def self.down
    remove_column "orders", "customer_comments"
  end
end
