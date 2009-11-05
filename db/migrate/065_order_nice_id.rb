class OrderNiceId < ActiveRecord::Migration
  def self.up
    add_column "orders", "job_number", :integer
  end

  def self.down
    remove_column "orders", "job_number"
  end
end
