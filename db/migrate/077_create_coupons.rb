class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.column :name, :string, :limit => 60
      t.column :code, :string, :limit => 24
      t.column :discount, :float
    end
  end

  def self.down
    drop_table :coupons
  end
end
