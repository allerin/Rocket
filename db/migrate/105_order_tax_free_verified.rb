class OrderTaxFreeVerified < ActiveRecord::Migration
  def self.up
    add_column "orders", "tax_free_verified", :boolean
  end

  def self.down
    remove_column "orders", "tax_free_verified"
  end
end
