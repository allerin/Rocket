class CreateMakeReadies < ActiveRecord::Migration
  def self.up
    create_table :make_readies do |t|
      t.column :product_id, :integer
      t.column :product_option_value_id, :integer
      t.column :price, :float
    end
  end

  def self.down
    drop_table :make_readies
  end
end
