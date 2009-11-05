class GetItStarted < ActiveRecord::Migration
  def self.up
    ## This is the starting point for our nomad dev db
    
    create_table :addresses do |addresses|
      addresses.column :customer_id, :integer, :null => false
      addresses.column :created_at, :datetime
      addresses.column :label, :string, :limit => 50
      addresses.column :first_name, :string, :limit => 92
      addresses.column :last_name, :string, :limit => 92
      addresses.column :company, :string, :limit => 92
      addresses.column :phone, :string, :limit => 32
      addresses.column :street_1, :string, :limit => 192
      addresses.column :street_2, :string, :limit => 192
      addresses.column :city, :string, :limit => 64
      addresses.column :state, :string, :limit => 64
      addresses.column :zip, :string, :limit => 16
      addresses.column :country, :string, :limit => 48
    end
    
    add_index :addresses, :customer_id
    
    create_table :customers do |customers|
      customers.column :created_at, :datetime
      customers.column :updated_at, :datetime
      customers.column :first_name, :string, :limit => 92
      customers.column :last_name, :string, :limit => 92
      customers.column :company, :string, :limit => 92
      customers.column :email, :string, :limit => 92
      customers.column :password, :string, :limit => 44
      customers.column :phone, :string, :limit => 32
      customers.column :fax, :string, :limit => 32
      customers.column :reseller_id, :string, :limit => 64
      customers.column :terms_credit, :float
      customers.column :kind, :string, :limit => 164
      
      #what are these here for?
      customers.column :billing_address_id, :integer
      customers.column :shipping_address_id, :integer      
    end
    
    add_index :customers, :email
    
    create_table :invoices do |invoices|
      invoices.column :created_at, :datetime
      invoices.column :updated_at, :datetime
      invoices.column :user_id, :integer
      invoices.column :customer_id, :integer
      invoices.column :address_id, :integer
    end
    
    create_table :jobs_product_options do | jpa |
      jpa.column :job_id, :integer
      jpa.column :product_option_value_id, :integer
    end
    
    create_table :jobs do | jobs |
      jobs.column :order_id, :integer
      jobs.column :product_id, :integer
      jobs.column :due_date, :datetime
      jobs.column :batch, :string, :limit => 8
      jobs.column :run, :integer
      jobs.column :shipping_address_id, :integer
      jobs.column :shipping_method_id, :integer
      jobs.column :proof_method_id, :integer
    end
    
    create_table :notes do | notes |
      notes.column :created_at, :datetime
      notes.column :user_id, :integer
      notes.column :record_id, :integer
      notes.column :type, :string, :limit => 64
      notes.column :content, :text
    end
    
    add_index :notes, :user_id
    add_index :notes, :record_id
    add_index :notes, :type
    add_index :notes, :created_at
    
    create_table :order_statuses do | os |
      os.column :order_id, :integer
      os.column :user_id, :integer
      os.column :status, :string, :limit => 32
      os.column :message, :text
      os.column :created_at, :datetime
    end
  
    add_index :order_statuses, :order_id
    add_index :order_statuses, :status
    add_index :order_statuses, :created_at
    
    create_table :orders do |orders|
      orders.column :invoice_id, :integer
      orders.column :product_id, :integer
      orders.column :quantity, :integer
      orders.column :price, :float, :size => "11,2"
      orders.column :address_id, :integer
      orders.column :shipping_method_id, :integer
      orders.column :shipping_price, :float, :size => "11,2"
      orders.column :proof_method_id, :integer
      orders.column :proof_price, :float, :size => "11,2"
      orders.column :tax, :float, :size => "11,2"
      orders.column :total, :float, :size => "11,2"
      orders.column :batch, :string, :size => 8
      orders.column :run, :integer
      orders.column :due_date, :date
      orders.column :status, :string, :size => 64
      orders.column :submit_method_id, :integer
    end
    
    add_index :orders, :invoice_id
    add_index :orders, :due_date
    
    create_table :orders_product_option_values do |opov|
      opov.column :order_id, :integer
      opov.column :product_option_value_id, :integer
    end
    
    add_index :orders_product_option_values, :order_id
    add_index :orders_product_option_values, :product_option_value_id  
      
    create_table :payments do | payments |
      payments.column :order_id, :integer
      payments.column :type, :string, :limit => 32
      payments.column :name, :string, :limit => 96
      payments.column :number, :integer
      payments.column :amount, :float, :size => "11,2"
      payments.column :approved, :boolean
      payments.column :result, :integer
      payments.column :pnref, :integer
      payments.column :auth, :integer
      payments.column :message, :string, :limit => 64
      payments.column :kind, :string, :limit => 32
      payments.column :exp_month, :integer
      payments.column :exp_year, :integer
      payments.column :created_at, :datetime
    end  
      
    add_index :payments, :order_id
    add_index :payments, :created_at
    
    create_table :product_option_values do | pov |
      pov.column :product_option_id, :integer
      pov.column :label, :string, :limit => 64
      pov.column :kind, :string, :limit => 16
      pov.column :price_per_unit, :float, :size => "11,2"
      pov.column :unit_quantity, :integer
      pov.column :price_per_sqin, :float, :size => "11,2"
      pov.column :price_rule, :string, :size => 64
    end
    
    create_table :product_options do | po |
      po.column :title, :string, :limit => 32
      po.column :setup_price, :float, :size => "11,2"
    end
    
    create_table :product_options_products do |pop|
      pop.column :product_id, :integer
      pop.column :product_option_id, :integer
      pop.column :required, :boolean
      pop.column :product_option_value_id, :integer  
    end
    
    create_table :products do |products|
      products.column :sku, :string, :length => 16
      products.column :height, :float, :length => "11,2"
      products.column :width, :float, :length => "11,2"
      products.column :title, :string, :length => 64
      products.column :description, :string, :length => 244
      products.column :setup_price, :float, :length => "11,2"
      products.column :product_code, :string, :length => 16
    end
    
    create_table :proof_methods do |pm|
      pm.column :name, :string, :length => 64
    end
    
    create_table :quantities do |q|
      q.column :first, :integer
      q.column :last, :integer
      q.column :step, :integer
    end
    
    create_table :roles do |r|
      r.column :title, :string, :length => 64
    end
    
    create_table :sales_reps do |sr|
      sr.column :name, :string, :length => 64
    end
    
    create_table :shipping_methods do |sm|
      sm.column :name, :string, :length => 64
    end
    
    create_table :submit_methods do |subm|
      subm.column :name, :string, :length => 32
    end
    
    create_table :users do |u|
      u.column :first_name, :string, :length => 127
      u.column :last_name, :string, :length => 127
      u.column :screen_name, :string, :length => 64
      u.column :password, :string, :length => 40
      u.column :role_id, :integer
    end
  end

  def self.down
  end
end
