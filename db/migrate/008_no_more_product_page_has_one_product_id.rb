class NoMoreProductPageHasOneProductId < ActiveRecord::Migration
  def self.up
    remove_column :product_pages, :product_id
  end

  def self.down
    add_column :product_pages, :product_id, :integer
  end
end
