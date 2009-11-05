class CreateDesignOrderOptionValues < ActiveRecord::Migration
  def self.up
    create_table :design_order_option_values do |t|
      t.column :design_order_id, :integer
      t.column :option_label, :string
      t.column :option_customer_label, :string
      t.column :value_label, :string
      t.column :value_customer_label, :string
      t.column :setup_price, :float
    end
  end

  def self.down
    drop_table :design_order_option_values
  end
end
