class OrderArtworkRecieved < ActiveRecord::Migration
  def self.up
    add_column "orders", "front_art_received", :boolean
    add_column "orders", "back_art_received", :boolean
    add_column "orders", "mailing_list_received", :boolean
  end

  def self.down
    remove_column "orders", "front_art_received"
    remove_column "orders", "back_art_received"
    remove_column "orders", "mailing_list_received"
  end
end
