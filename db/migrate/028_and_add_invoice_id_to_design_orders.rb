class AndAddInvoiceIdToDesignOrders < ActiveRecord::Migration
  def self.up
    add_column "payments", "invoice_id", :integer
    add_column "orders", "custom_name", :string
    rename_column "design_orders", "design_id", "parent_id"
  end

  def self.down
    remove_column "payments", "invoice_id"
    remove_column "orders", "custom_name"
    rename_column "design_orders", "parent_id", "design_id"
  end
end
