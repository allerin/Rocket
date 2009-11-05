class PaymentNumberString < ActiveRecord::Migration
  def self.up
    change_column :payments, :number, :string, :limit => 16
  end

  def self.down
  end
end
