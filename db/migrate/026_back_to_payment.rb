class BackToPayment < ActiveRecord::Migration
  def self.up
    rename_table "transactions", "payments"
  end

  def self.down
    rename_table "payments", "transactions"
  end
end
