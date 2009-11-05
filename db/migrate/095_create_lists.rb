class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.column  :order_id, :integer
      t.column  :data, :longblob
      t.column  :created_at, :datetime
      t.column  :filename, :string
    end
  end

  def self.down
    drop_table :lists
  end
end
