class CustomerSendPromo < ActiveRecord::Migration
  def self.up
    add_column "customers", "send_promo", :boolean
  end

  def self.down
    remove_column "customers", "send_promo"
  end
end
