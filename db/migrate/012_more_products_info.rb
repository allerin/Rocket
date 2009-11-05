class MoreProductsInfo < ActiveRecord::Migration
  def self.up
    add_column :products, :clarifying_info, :string
  end

  def self.down
    remove_column :products, :clarifying_info
  end
end
