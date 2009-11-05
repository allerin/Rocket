class PnrefGetItRight < ActiveRecord::Migration
  def self.up
    change_column :payments, :pnref, :string
  end

  def self.down
    change_column :payments, :pnref, :integer
  end
end
