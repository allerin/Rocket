class AlterPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :side, :string
  end

  def self.down
    remove_column :pictures, :side
  end
end
