class CreateBoxedProducts < ActiveRecord::Migration
  def self.up
    create_table :boxed_products do |t|
      t.column :box_id, :integer
      t.column :product_id, :integer
      t.column :coating_id, :integer
      t.column :max_quantity, :integer
    end
  end

  def self.down
    drop_table :boxed_products
  end
end
