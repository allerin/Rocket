class OrderProductOptionValueNeverVisible < ActiveRecord::Migration
  def self.up
    add_column "order_product_option_values", "never_visible", :boolean
  end

  def self.down
    remove_column "order_product_option_values", "never_visible"
  end
end
