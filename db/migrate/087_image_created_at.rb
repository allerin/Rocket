class ImageCreatedAt < ActiveRecord::Migration
  def self.up
    add_column "images", "created_at", :datetime
  end

  def self.down
    remove_column "images", "created_at"
  end
end
