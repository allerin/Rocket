class PaymentCapturedAt < ActiveRecord::Migration
  def self.up
    add_column "payments", "captured_at", :datetime
  end

  def self.down
    remove_column "payments", "captured_at"
  end
end
