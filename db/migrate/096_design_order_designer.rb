class DesignOrderDesigner < ActiveRecord::Migration
  def self.up
    add_column "design_orders", "designer", :string
  end

  def self.down
    remove_column "design_orders", "designer"
  end
end
