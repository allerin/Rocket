class ShippingMethodStuff < ActiveRecord::Migration
  def self.up
    add_column "shipping_methods", "ups_service_code", :string
  end

  def self.down
    remove_column "shipping_methods", "ups_service_code"
  end
end
