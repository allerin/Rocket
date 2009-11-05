class CreateOrderProductOptionValues < ActiveRecord::Migration
  def self.up
    create_table :order_product_option_values do |t|
       t.column :order_id, :integer
       t.column :title, :string
       t.column :label, :string
       t.column :kind, :string
       t.column :setup_price, :float
       t.column :price_per_unit, :float
       t.column :unit_quantity, :integer
       t.column :price_per_sqin, :float
       t.column :price_rule, :string
       t.column :customer_label, :string
    end
  end

  def self.down
    drop_table :order_product_option_values
  end
end
