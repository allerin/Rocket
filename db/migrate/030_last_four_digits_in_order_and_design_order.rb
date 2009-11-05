class LastFourDigitsInOrderAndDesignOrder < ActiveRecord::Migration
  def self.up
    add_column "invoices", "last_four", :string
  end

  def self.down
    remove_column "invoices", "last_four"
  end
end
