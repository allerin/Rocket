class InvoiceSentAt < ActiveRecord::Migration
  def self.up
    add_column "invoices", "sent_at", :datetime
  end

  def self.down
    remove_column "invoices", "sent_at"
  end
end
