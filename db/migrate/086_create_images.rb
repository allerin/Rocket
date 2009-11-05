class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :order_id, :integer
      t.column :side, :string, :limit => 1
      t.column :filename, :string
    end
  end

  def self.down
    drop_table :images
  end
end
