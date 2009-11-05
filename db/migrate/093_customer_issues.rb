class CustomerIssues < ActiveRecord::Migration
  def self.up
    add_column "customers", "issues", :string
  end

  def self.down
    remove_column "customers", "issues"
  end
end
