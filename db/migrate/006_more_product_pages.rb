class MoreProductPages < ActiveRecord::Migration
  def self.up
    remove_column :product_pages, :page_html
    add_column :product_pages, :description_html, :text
    add_column :product_pages, :features_html, :text
  end

  def self.down
    add_column :product_pages, :page_html, :text
    remove_column :product_pages, :description_html
    remove_column :product_pages, :features_html
  end
end
