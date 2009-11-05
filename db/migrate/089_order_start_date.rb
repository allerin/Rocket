class OrderStartDate < ActiveRecord::Migration
  def self.up
    add_column "orders", "start_date", :datetime
  end

  def self.down
    remove_column "orders", "start_date"
  end
end
