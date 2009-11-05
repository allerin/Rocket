class AddPickedupDateOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :pickedup_date, :datetime
  end

  def self.down
    remove_column :orders, :pickedup_date
  end
end
