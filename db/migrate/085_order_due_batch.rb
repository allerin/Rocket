class OrderDueBatch < ActiveRecord::Migration
  def self.up
    add_column "orders", "due_batch", :string, :limit => 8
    change_column "orders", "due_date", :datetime
  end

  def self.down
    remove_column "orders", "due_batch"
  end
end
