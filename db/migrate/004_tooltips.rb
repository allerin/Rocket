class Tooltips < ActiveRecord::Migration
  def self.up
    add_column :product_option_values, :tooltip, :text
  end

  def self.down
    remove_column :product_option_values, :tooltip
  end
end
