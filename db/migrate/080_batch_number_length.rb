class BatchNumberLength < ActiveRecord::Migration
  def self.up
     change_column(:orders, :batch, :string, :limit => 8)
  end

  def self.down
    change_column(:orders, :batch, :string, :limit => 6)
  end
end
