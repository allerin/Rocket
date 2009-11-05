class CreatePackages < ActiveRecord::Migration
  def self.up
    create_table :packages do |t|
      t.column :title, :string
      t.column :title_image, :string
    end
  end

  def self.down
    drop_table :packages
  end
end
