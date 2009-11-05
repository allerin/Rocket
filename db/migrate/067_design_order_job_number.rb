class DesignOrderJobNumber < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "job_number", :integer, :default => 0
  end

  def self.down
    remove_column "design_orders", "job_number"
  end
end
