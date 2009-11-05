class AddInvoiceIdToDesignOrder < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "invoice_id", :integer
  end

  def self.down
    remove_column "design_orders", "invoice_id"
  end
end
