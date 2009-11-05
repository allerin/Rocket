class PaymentCaptured < ActiveRecord::Migration
  def self.up
    add_column "payments", "captured", :boolean
  end

  def self.down
    remove_column "payments", "captured"
  end
end
