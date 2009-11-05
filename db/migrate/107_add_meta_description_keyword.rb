class AddMetaDescriptionKeyword < ActiveRecord::Migration
  def self.up
    add_column "product_pages", "meta_description", :string
    add_column "product_pages", "meta_keywords", :string
  end

  def self.down
    remove_column "product_pages", "meta_description"
    remove_column "product_pages", "meta_keywords"
  end
end
