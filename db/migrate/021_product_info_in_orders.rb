class ProductInfoInOrders < ActiveRecord::Migration
  def self.up
    add_column "orders", "product_sku", :string
    add_column "orders", "product_height", :float
    add_column "orders", "product_width", :float
    add_column "orders", "product_title", :string
    add_column "orders", "product_code", :string
    add_column "orders", "product_setup_price", :float
    add_column "orders", "product_markup", :float
    add_column "products", "weight_per_unit", :float
    add_column "products", "weight_unit_size", :integer
    add_column "orders", "product_weight_per_unit", :float
    add_column "orders", "product_weight_unit_size", :integer
    drop_table "orders_product_option_values" 
    add_column "orders", "mailing_quantity", :integer
    add_column "orders", "mailing_price", :float
  end

  def self.down
    remove_column "orders", "product_sku"
    remove_column "orders", "product_height"
    remove_column "orders", "product_width"
    remove_column "orders", "product_title"
    remove_column "orders", "product_code"
    remove_column "products", "weight_per_unit"
    remove_column "products", "unit_size"
    remove_column "orders", "product_setup_price"
    remove_column "orders", "product_weight_per_unit"
    remove_column "orders", "product_unit_size"
    remove_column "orders", "product_markup"
    
    create_table "orders_product_option_values", :id => false, :force => true do |t|
      t.column "order_id", :integer, :limit => 10
      t.column "product_option_value_id", :integer, :limit => 10
    end
    remove_column "orders", "mailing_quantity"
    remove_column "orders", "mailing_price"
  end
end
