class CreatePostages < ActiveRecord::Migration
  def self.up
    create_table("postages", :id => true) do |t|
       t.column :min_quantity, :int
       t.column :mailing_option_value_id, :int
       t.column :price, :float
      t.column :product_id, :int
    end
    
  end

  def self.down
    drop_table :postages
  end
end
