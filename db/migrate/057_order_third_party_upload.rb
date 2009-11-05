class OrderThirdPartyUpload < ActiveRecord::Migration
  def self.up
    add_column "orders", "art_upload_method", :string
    add_column "orders", "list_upload_method", :string
  end

  def self.down
    remove_column "orders", "art_upload_method"
    remove_column "orders", "list_upload_method"
  end
end
