class RunAAndB < ActiveRecord::Migration
  def self.up
    rename_column "orders", "run", "run_a"
    add_column "orders", "run_b", :integer
  end

  def self.down
    rename_column "orders", "run_a", "run"
    remove_column "orders", "run_b"
  end
end
