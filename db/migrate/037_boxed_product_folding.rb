class BoxedProductFolding < ActiveRecord::Migration
  def self.up
    add_column "boxed_products", "folding_id", :integer
  end

  def self.down
    remove_column "boxed_products", "folding_id"
  end
end
