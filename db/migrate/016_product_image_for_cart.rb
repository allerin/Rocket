class ProductImageForCart < ActiveRecord::Migration
  def self.up
    add_column :products, :cart_image, :string
  end

  def self.down
    remove_column :products, :cart_image
  end
end
