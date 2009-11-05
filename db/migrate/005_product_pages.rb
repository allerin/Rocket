class ProductPages < ActiveRecord::Migration
  def self.up
    create_table :product_pages do |pp|
      pp.column :name, :string
      pp.column :title, :string
      pp.column :product_id, :integer
      pp.column :page_html, :text
    end
  end

  def self.down
    drop_table :product_pages
  end
end
