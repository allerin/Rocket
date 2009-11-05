class OrderMailHouseBoolean < ActiveRecord::Migration
  def self.up
    change_column :orders, :mail_house, :boolean
  end

  def self.down
  end
end
