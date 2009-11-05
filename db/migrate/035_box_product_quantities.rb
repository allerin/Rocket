class BoxProductQuantities < ActiveRecord::Migration
  def self.up
    drop_table "boxes_products"
  end

  def self.down
  
    
    create_table "boxes_products", :id => false, :force => true do |t|
      t.column "box_id", :integer, :default => 0, :null => false
      t.column "product_id", :integer, :default => 0, :null => false
      t.column "max_quantity", :integer, :default => 0, :null => false
    end
  end
end
