class PostageInOrder < ActiveRecord::Migration
  def self.up
    add_column "orders", "postage_price", :float
  end

  def self.down
    remove_column "orders", "postage_price"
  end
end
