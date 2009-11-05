class CreatePackageItemOptionValues < ActiveRecord::Migration
  def self.up
    create_table :package_item_option_values do |t|
       t.column :package_item_id, :integer
       t.column :product_option_value_id, :integer
    end
  end

  def self.down
    drop_table :package_item_option_values
  end
end
