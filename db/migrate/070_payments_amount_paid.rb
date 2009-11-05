class PaymentsAmountPaid < ActiveRecord::Migration
  def self.up
    add_column "payments", "amount_paid", :float, :default => 0
  end

  def self.down
    remove_column "payments", "amount_paid"
  end
end
