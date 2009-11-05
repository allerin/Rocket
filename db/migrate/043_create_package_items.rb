class CreatePackageItems < ActiveRecord::Migration
  def self.up
    create_table :package_items do |t|
       t.column :product_id, :integer
       t.column :package_id, :integer
       t.column :divisible, :boolean
       t.column :max_divisor, :integer
    end
  end

  def self.down
    drop_table :package_items
  end
end
