class Boxes < ActiveRecord::Migration
  def self.up
    create_table( :boxes ) do | b |
      b.column :label, :string
      b.column :width, :float
      b.column :height, :float
      b.column :depth, :float
      b.column :weight, :float
      b.column :filler_weight, :float
    end
    
    create_table( :boxes_products, :id => false ) do |bp|
      bp.column :box_id, :integer
      bp.column :product_id, :integer
      bp.column :max_quantity, :integer
    end
  end

  def self.down
    drop_table :boxes
    drop_table :boxes_products
  end
end
