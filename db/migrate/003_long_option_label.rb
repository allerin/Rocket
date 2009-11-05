class LongOptionLabel < ActiveRecord::Migration
  def self.up
    add_column :product_option_values, :customer_label, :string
  end

  def self.down
    remove_column :product_option_values, :customer_label
  end
end
