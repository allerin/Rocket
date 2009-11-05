class CommentKind < ActiveRecord::Migration
  def self.up
    add_column "comments", "kind", :string, :limit => 12
  end

  def self.down
    remove_column "comments", "kind"
  end
end
