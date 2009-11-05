class ProductDesignPrices < ActiveRecord::Migration
  def self.up
    add_column "products", "one_sided_design_price", :float
    add_column "products", "two_sided_design_price", :float
  end

  def self.down
    remove_column "products", "one_sided_design_price"
    remove_column "products", "two_sided_design_price"
  end
end
