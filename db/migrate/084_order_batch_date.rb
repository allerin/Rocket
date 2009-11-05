class OrderBatchDate < ActiveRecord::Migration
  def self.up
    add_column "orders", "batch_date", :datetime
  end

  def self.down
    remove_column "orders", "batch_date"
  end
end
