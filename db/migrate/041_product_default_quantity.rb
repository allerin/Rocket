class ProductDefaultQuantity < ActiveRecord::Migration
  def self.up
    add_column "products", "default_quantity", :integer
  end

  def self.down
    remove_column "products", "default_quantity"
  end
end
