class Indexes < ActiveRecord::Migration
  def self.up
    add_index :order_statuses, [:order_id, :status, :created_at], :name => "statuses"
    add_index :order_product_option_values, [:order_id, :title], :name => "order_id_and_title"
    add_index :invoices, [:customer_id], :name => "customer"
    add_index :customers, [:email], :name => "email"
    add_index :payments, [:order_id, :created_at], :name => "order_created"
  end

  def self.down
    remove_index :order_statuses, :name => :statuses
    remove_index :order_product_option_values, :name => :order_id_and_title
    remove_index :invoices, :name => :customer
    remove_index :customers, :name => :email
    remove_index :payments, :name => :order
  end
end
