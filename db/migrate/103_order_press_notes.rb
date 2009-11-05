class OrderPressNotes < ActiveRecord::Migration
  def self.up
    add_column "orders", "press_notes", :text
  end

  def self.down
    remove_column "orders", "press_notes"
  end
end
