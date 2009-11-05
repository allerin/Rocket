class ProductOptionValuePostMarkup < ActiveRecord::Migration
  def self.up
    add_column "product_option_values", "post_markup", :integer
  end

  def self.down
    remove_column "product_option_values", "post_markup"
  end
end
