class DesignOrderFullJobNo < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "full_job_number", :string, :limit => 10
  end

  def self.down
    remove_column "design_orders", "full_job_number"
  end
end
