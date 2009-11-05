class DesignOptions < ActiveRecord::Migration
  def self.up
    create_table "design_options" do |t|
      t.column :label, :string
      t.column :customer_label, :string
    end
    
    create_table "design_option_values" do |t|
      t.column :design_option_id, :integer
      t.column :label, :string
      t.column :customer_label, :string
      t.column :default, :boolean
      t.column :setup_price, :float
    end
  end

  def self.down
    drop_table "design_options"
    drop_table "design_option_values"
  end
end
