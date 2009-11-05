class CreateDesigns < ActiveRecord::Migration
  def self.up
    create_table :design_orders do |t|
       t.column :custom_name, :string
       t.column :address_id, :integer
       t.column :shipping_method_id, :integer
       t.column :design_id, :integer
       t.column :order_id, :integer
       t.column :product_id, :integer
       t.column :copy, :text
       t.column :comments, :text
       t.column :price, :float
       t.column :tax, :float
       t.column :shipping_price, :float
       t.column :total, :float
    end
    add_column "transactions", "design_order_id", :integer
  end

  def self.down
    drop_table :designs
    remove_column "transactions", "design_order_id"
  end
end
