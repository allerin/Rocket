class OptionValueTurnaroundOffset < ActiveRecord::Migration
  def self.up
    add_column "product_option_values", "turnaround_offset", :integer
    add_column "order_product_option_values", "turnaround_offset", :integer
  end

  def self.down
    remove_column "product_option_values", "turnaround_offset"
    remove_column "order_product_option_values", "turnaround_offset"
  end
end
