class CreateExtraCharges < ActiveRecord::Migration
  def self.up
    create_table :extra_charges do |t|
      t.column :name, :string, :limit => 64
      t.column :price, :float
      t.column :order_id, :integer
      t.column :design_order_id, :integer
    end
    
    add_index :extra_charges, :order_id
    add_index :extra_charges, :design_order_id
  end

  def self.down
    drop_table :extra_charges
  end
end
