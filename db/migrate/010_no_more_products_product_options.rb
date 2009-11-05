class NoMoreProductsProductOptions < ActiveRecord::Migration
  def self.up
    drop_table :product_options_products
  end

  def self.down
    create :product_options_products do |pop|
      pop.column :product_id, :integer
      pop.column :product_option_id, :integer
      pop.column :required, :boolean
      pop.column :product_option_value_id, :integer
    end
  end
end
