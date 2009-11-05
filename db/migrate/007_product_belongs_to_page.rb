class ProductBelongsToPage < ActiveRecord::Migration
  def self.up
    add_column :products, :product_page_id, :integer
  end

  def self.down
    remove_column :products, :product_page_id
  end
end
