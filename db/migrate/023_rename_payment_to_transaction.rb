class RenamePaymentToTransaction < ActiveRecord::Migration
  def self.up
    rename_table "payments", "transactions"
  end

  def self.down
    rename_table "transactions", "payments"
  end
end
