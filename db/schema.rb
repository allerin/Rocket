# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 110) do

  create_table "addresses", :force => true do |t|
    t.integer "customer_id", :limit => 20, :default => 0, :null => false
    t.string  "label",       :limit => 50
    t.string  "first_name",  :limit => 40
    t.string  "last_name",   :limit => 40
    t.string  "company",     :limit => 80
    t.string  "phone",       :limit => 12
    t.string  "street_1",    :limit => 50
    t.string  "street_2",    :limit => 50
    t.string  "city",        :limit => 25
    t.string  "state",       :limit => 2
    t.string  "zip",         :limit => 10
    t.string  "country",     :limit => 25
  end

  add_index "addresses", ["customer_id"], :name => "customer_id"
  add_index "addresses", ["first_name"], :name => "first_name"
  add_index "addresses", ["last_name"], :name => "last_name"
  add_index "addresses", ["street_1"], :name => "street_1"
  add_index "addresses", ["city"], :name => "city"
  add_index "addresses", ["state"], :name => "state"

  create_table "boxed_products", :force => true do |t|
    t.integer "box_id"
    t.integer "product_id"
    t.integer "coating_id"
    t.integer "max_quantity"
    t.integer "folding_id"
  end

  create_table "boxes", :force => true do |t|
    t.string "label"
    t.float  "width"
    t.float  "height"
    t.float  "depth"
    t.float  "weight"
    t.float  "filler_weight"
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.datetime "created_at",                                     :null => false
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
    t.string   "kind",             :limit => 12
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"
  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id"

  create_table "coupon_assignments", :force => true do |t|
    t.integer "coupon_id"
    t.integer "product_id"
  end

  create_table "coupons", :force => true do |t|
    t.string "name",     :limit => 60
    t.string "code",     :limit => 24
    t.float  "discount"
  end

  create_table "customers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",          :limit => 25
    t.string   "last_name",           :limit => 30
    t.string   "company",             :limit => 50
    t.string   "email",               :limit => 80
    t.string   "password",            :limit => 44
    t.integer  "billing_address_id",  :limit => 20
    t.integer  "shipping_address_id", :limit => 20
    t.string   "phone",               :limit => 20
    t.string   "fax",                 :limit => 20
    t.string   "reseller_id",         :limit => 20
    t.float    "terms_credit"
    t.string   "kind",                :limit => 150
    t.boolean  "confirm_updated"
    t.boolean  "send_promo"
    t.string   "account_rep",         :limit => 40
    t.boolean  "reseller_on_file"
    t.string   "issues"
  end

  add_index "customers", ["email"], :name => "email"

  create_table "design_option_values", :force => true do |t|
    t.integer "design_option_id"
    t.string  "label"
    t.string  "customer_label"
    t.boolean "default"
    t.float   "setup_price"
  end

  create_table "design_options", :force => true do |t|
    t.string "label"
    t.string "customer_label"
  end

  create_table "design_order_option_values", :force => true do |t|
    t.integer "design_order_id"
    t.string  "option_label"
    t.string  "option_customer_label"
    t.string  "value_label"
    t.string  "value_customer_label"
    t.float   "setup_price"
  end

  create_table "design_orders", :force => true do |t|
    t.string   "custom_name"
    t.integer  "address_id"
    t.integer  "shipping_method_id"
    t.integer  "parent_id"
    t.integer  "order_id"
    t.integer  "product_id"
    t.text     "copy"
    t.text     "comments"
    t.float    "price"
    t.float    "tax"
    t.float    "shipping_price"
    t.float    "total"
    t.integer  "invoice_id"
    t.integer  "job_number",                       :default => 0
    t.string   "designer"
    t.string   "full_job_number",    :limit => 10
    t.string   "status",             :limit => 40
    t.datetime "created_at"
    t.datetime "paid_at"
    t.datetime "commission_paid_at"
  end

  create_table "extra_charges", :force => true do |t|
    t.string  "name",            :limit => 64
    t.float   "price"
    t.integer "order_id"
    t.integer "design_order_id"
  end

  add_index "extra_charges", ["order_id"], :name => "index_extra_charges_on_order_id"
  add_index "extra_charges", ["design_order_id"], :name => "index_extra_charges_on_design_order_id"

  create_table "images", :force => true do |t|
    t.integer  "order_id"
    t.string   "side",       :limit => 1
    t.string   "filename"
    t.datetime "created_at"
  end

  create_table "imports", :id => false, :force => true do |t|
    t.text "AECustomerType"
    t.text "AEDiscount"
    t.text "AEFreightTax"
    t.text "AEJournal"
    t.text "AEQuantity"
    t.text "AESales"
    t.text "AESalesStatus"
    t.text "AETaxCode"
    t.text "AETerms1"
    t.text "AETerms2"
    t.text "AETerms3"
    t.text "AETerms4"
    t.text "AETerms5"
    t.text "aging_30_59_calc"
    t.text "aging_60_89_calc"
    t.text "aging_current_calc"
    t.text "aging_plus90deliquent_calc"
    t.text "Amount_Due"
    t.text "Amount_Due_Summary"
    t.text "Amount_Paid"
    t.text "Amount_Paid_Summary"
    t.text "auth_code"
    t.text "auth_result"
    t.text "a_r_date_marker"
    t.text "a_r_grand_sum_30_59"
    t.text "a_r_grand_sum_60_89"
    t.text "a_r_grand_sum_90_plus"
    t.text "a_r_grand_sum_amt_due"
    t.text "a_r_grand_sum_current"
    t.text "a_r_sum_30_59"
    t.text "a_r_sum_60_89"
    t.text "a_r_sum_90_delequent"
    t.text "a_r_sum_current"
    t.text "B_Fax"
    t.text "batch_calc_field"
    t.text "Batch_Num"
    t.text "Billing_Method"
    t.text "Birth_Date"
    t.text "Blank1"
    t.text "Blank11"
    t.text "Blank12"
    t.text "Blank13"
    t.text "Blank14"
    t.text "Blank15"
    t.text "Blank16"
    t.text "Blank17"
    t.text "Blank18"
    t.text "Blank19"
    t.text "Blank2"
    t.text "Blank20"
    t.text "Blank3"
    t.text "Blank4"
    t.text "Blank5"
    t.text "Blank6"
    t.text "Blank7"
    t.text "Blank8"
    t.text "Blank9"
    t.text "boxes_large"
    t.text "boxes_med"
    t.text "boxes_poster"
    t.text "boxes_small"
    t.text "B_Address"
    t.text "B_City"
    t.text "B_Company"
    t.text "B_Country"
    t.text "B_email"
    t.text "B_First_Name"
    t.text "B_Last_Name"
    t.text "B_Phone"
    t.text "B_State"
    t.text "B_ZIP"
    t.text "CA_Sales_Tax"
    t.text "CA_Sales_Tax_Summary"
    t.text "CA_Resale_Num"
    t.text "CC"
    t.text "CCLast4"
    t.text "CC_exp"
    t.text "Check_Pound"
    t.text "Check_Cleared"
    t.text "Checkholder"
    t.text "Check_Num"
    t.text "ColorType"
    t.text "CreateDate"
    t.text "CurrentHour"
    t.text "CurrentRecordID"
    t.text "cust_pick_up_name"
    t.text "cvv2"
    t.text "DSO10000"
    t.text "DSO2000"
    t.text "DSO3000"
    t.text "DSO4000"
    t.text "DSO500"
    t.text "DSO5000"
    t.text "DSO6000"
    t.text "DSO7000"
    t.text "DSO8000"
    t.text "DSO9000"
    t.text "DSP1000"
    t.text "DSP10000"
    t.text "DSP2000"
    t.text "DSP3000"
    t.text "DSP4000"
    t.text "DSP500"
    t.text "DSP5000"
    t.text "DSP6000"
    t.text "DSP7000"
    t.text "DSP8000"
    t.text "DSP9000"
    t.text "DSS1000"
    t.text "DSS2000"
    t.text "DSS3000"
    t.text "DSS4000"
    t.text "DSS500"
    t.text "DSS5000"
    t.text "DSS6000"
    t.text "DSS7000"
    t.text "DSS8000"
    t.text "DSS9000"
    t.text "DueDate"
    t.text "Filename_1"
    t.text "Filename_2"
    t.text "Filename_3"
    t.text "FilesApproved"
    t.text "Find_field_for_month_paid"
    t.text "find_sales_tax_calc"
    t.text "FlightChecked"
    t.text "follow_up_required"
    t.text "Full_Ship_Name"
    t.text "golbal_batch"
    t.text "HiddenDate"
    t.text "HiddenTime"
    t.text "ID_Pound"
    t.text "ID_Type"
    t.text "job_status"
    t.text "job_status_find_calc"
    t.text "Kind"
    t.text "mailing_postage_description"
    t.text "mailing_postage_paid"
    t.text "mailing_postage_price"
    t.text "mailing_serv_description"
    t.text "mailing_serv_price"
    t.text "Miva_Order_Date"
    t.text "Miva_Order_ID"
    t.text "Miva_Order_Time"
    t.text "no_of_boxes"
    t.text "On_Account"
    t.text "onRunA"
    t.text "onRunB"
    t.text "Order_Quantity"
    t.text "Order_Total"
    t.text "Order_Total_Summary"
    t.text "p_slash_u_date"
    t.text "PaidDateField"
    t.text "PickOfWeek"
    t.text "pn_ref"
    t.text "PPCode"
    t.text "PPCode2"
    t.text "PPName"
    t.text "PPName2"
    t.text "PPPrice"
    t.text "PPPrice_Summary"
    t.text "PPPrice2"
    t.text "PrePress_Comments"
    t.text "Press_Comments"
    t.text "Price_subtotal"
    t.text "Price_Subtotal_Summary"
    t.text "Product_Code10"
    t.text "Product_Code2"
    t.text "Product_Code3"
    t.text "Product_Code4"
    t.text "Product_Code5"
    t.text "Product_Code6"
    t.text "Product_Code7"
    t.text "Product_Code8"
    t.text "Product_Code9"
    t.text "Product_Description"
    t.text "Product_Name10"
    t.text "Product_Name2"
    t.text "Product_Name3"
    t.text "Product_Name4"
    t.text "Product_Name5"
    t.text "Product_Name6"
    t.text "Product_Name7"
    t.text "Product_Name8"
    t.text "Product_Name9"
    t.text "Product_Price10"
    t.text "Product_Price2"
    t.text "Product_Price3"
    t.text "Product_Price4"
    t.text "Product_Price5"
    t.text "Product_Price6"
    t.text "Product_Price7"
    t.text "Product_Price8"
    t.text "Product_Price9"
    t.text "Product_Quantity10"
    t.text "Product_Quantity2"
    t.text "Product_Quantity3"
    t.text "Product_Quantity4"
    t.text "Product_Quantity5"
    t.text "Product_Quantity6"
    t.text "Product_Quantity7"
    t.text "Product_Quantity8"
    t.text "Product_Quantity9"
    t.text "Product_Code1"
    t.text "Product_Name1"
    t.text "Product_Price1"
    t.text "Product_Quantity1"
    t.text "ProofMethod"
    t.text "ProofTotal"
    t.text "PS_RefPound"
    t.text "p_u_date"
    t.text "p_u_time"
    t.text "Rocket_Order_Num"
    t.text "Sales_Rep"
    t.text "Shipping_Price10"
    t.text "Shipping_Price2"
    t.text "Shipping_Price3"
    t.text "Shipping_Price4"
    t.text "Shipping_Price5"
    t.text "Shipping_Price6"
    t.text "Shipping_Price7"
    t.text "Shipping_Price8"
    t.text "Shipping_Price9"
    t.text "Shipping_subtotal"
    t.text "Shipping_Subtotal_Summary"
    t.text "Shipping_Method"
    t.text "Shipping_Price1"
    t.text "Special_Instructions"
    t.text "SSO1000"
    t.text "SSO10000"
    t.text "SSO2000"
    t.text "SSO3000"
    t.text "SSO4000"
    t.text "SSO500"
    t.text "SSO5000"
    t.text "SSO6000"
    t.text "SSO7000"
    t.text "SSO8000"
    t.text "SSO9000"
    t.text "SSP1000"
    t.text "SSP10000"
    t.text "SSP2000"
    t.text "SSP3000"
    t.text "SSP4000"
    t.text "SSP500"
    t.text "SSP5000"
    t.text "SSP6000"
    t.text "SSP7000"
    t.text "SSP8000"
    t.text "SSP9000"
    t.text "SSS1000"
    t.text "SSS10000"
    t.text "SSS2000"
    t.text "SSS3000"
    t.text "SSS4000"
    t.text "SSS500"
    t.text "SSS5000"
    t.text "SSS6000"
    t.text "SSS7000"
    t.text "SSS8000"
    t.text "SSS9000"
    t.text "Status"
    t.text "status_current_date"
    t.text "SubmitMethod"
    t.text "S_Address"
    t.text "S_City"
    t.text "S_Company"
    t.text "S_Country"
    t.text "S_email"
    t.text "S_Fax"
    t.text "S_First_Name"
    t.text "S_Last_Name"
    t.text "S_Phone"
    t.text "S_State"
    t.text "S_ZIP"
    t.text "Trade_Applied"
    t.text "Trade_Value"
  end

  create_table "invoices", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     :limit => 20
    t.integer  "customer_id", :limit => 20, :default => 0, :null => false
    t.integer  "address_id",  :limit => 20
    t.string   "last_four"
    t.datetime "sent_at"
  end

  add_index "invoices", ["customer_id"], :name => "customer"

  create_table "job_product_options", :id => false, :force => true do |t|
    t.integer "job_id",                  :limit => 10
    t.integer "product_option_value_id", :limit => 10
  end

  create_table "jobs", :force => true do |t|
    t.integer "order_id",            :limit => 20
    t.integer "product_id",          :limit => 10
    t.date    "due_date"
    t.string  "batch",               :limit => 6
    t.integer "run",                 :limit => 4
    t.integer "shipping_address_id", :limit => 20
    t.integer "shipping_method_id"
    t.integer "proof_method_id",     :limit => 10
  end

  create_table "lists", :force => true do |t|
    t.integer  "order_id"
    t.binary   "data"
    t.datetime "created_at"
    t.string   "filename"
  end

  create_table "make_readies", :force => true do |t|
    t.integer "product_id"
    t.integer "product_option_value_id"
    t.float   "price"
  end

  create_table "notes", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id",    :limit => 10
    t.integer  "record_id",  :limit => 20
    t.string   "type",       :limit => 50
    t.text     "content"
  end

  add_index "notes", ["user_id"], :name => "user_id"
  add_index "notes", ["record_id"], :name => "record_id"
  add_index "notes", ["type"], :name => "type"
  add_index "notes", ["created_at"], :name => "created_at"

  create_table "option_price_zones", :force => true do |t|
    t.integer "max_quantity"
    t.float   "setup_price"
    t.integer "unit_quantity"
    t.float   "price_per_unit"
  end

  create_table "option_price_zones_product_option_values", :id => false, :force => true do |t|
    t.integer "option_price_zone_id"
    t.integer "product_option_value_id"
  end

  create_table "order_product_option_values", :force => true do |t|
    t.integer "order_id"
    t.string  "title"
    t.string  "label"
    t.string  "kind"
    t.float   "setup_price"
    t.float   "price_per_unit"
    t.integer "unit_quantity"
    t.float   "price_per_sqin"
    t.string  "price_rule"
    t.string  "customer_label"
    t.boolean "never_visible"
    t.integer "turnaround_offset"
  end

  add_index "order_product_option_values", ["order_id", "title"], :name => "order_id_and_title"

  create_table "order_statuses", :force => true do |t|
    t.integer  "order_id",   :limit => 10
    t.integer  "user_id",    :limit => 10
    t.string   "status",     :limit => 20
    t.text     "message"
    t.datetime "created_at"
  end

  add_index "order_statuses", ["order_id", "status", "created_at"], :name => "statuses"

  create_table "orders", :force => true do |t|
    t.integer  "invoice_id",                :limit => 20
    t.integer  "product_id",                :limit => 10
    t.integer  "quantity"
    t.float    "price",                     :limit => 11
    t.integer  "address_id",                :limit => 20
    t.integer  "shipping_method_id"
    t.float    "shipping_price",            :limit => 11
    t.integer  "proof_method_id",           :limit => 10
    t.float    "proof_price",               :limit => 11
    t.float    "tax",                       :limit => 11
    t.float    "total",                     :limit => 11
    t.string   "batch",                     :limit => 8
    t.integer  "run_a",                     :limit => 4
    t.datetime "due_date"
    t.string   "status",                    :limit => 50
    t.integer  "submit_method_id"
    t.string   "product_sku"
    t.float    "product_height"
    t.float    "product_width"
    t.string   "product_title"
    t.string   "product_code"
    t.float    "product_setup_price"
    t.float    "product_markup"
    t.float    "product_weight_per_unit"
    t.integer  "product_weight_unit_size"
    t.integer  "mailing_quantity"
    t.float    "mailing_price"
    t.string   "custom_name"
    t.boolean  "front_art_received"
    t.boolean  "back_art_received"
    t.boolean  "mailing_list_received"
    t.float    "postage_price"
    t.string   "art_upload_method"
    t.string   "list_upload_method"
    t.integer  "job_number"
    t.boolean  "reprint"
    t.string   "reseller_id",               :limit => 20
    t.boolean  "mail_house"
    t.string   "customer_comments"
    t.string   "coupon_code",               :limit => 20
    t.integer  "run_b"
    t.datetime "paid_at"
    t.datetime "batch_date"
    t.string   "due_batch",                 :limit => 8
    t.datetime "start_date"
    t.integer  "product_turnaround_offset",               :default => 0
    t.string   "account_rep",               :limit => 40
    t.datetime "created_at"
    t.text     "press_notes"
    t.boolean  "tax_free_verified"
    t.datetime "pickedup_date"
  end

  create_table "package_item_option_values", :force => true do |t|
    t.integer "package_item_id"
    t.integer "product_option_value_id"
    t.integer "default",                 :limit => 1
  end

  create_table "package_items", :force => true do |t|
    t.integer "product_id"
    t.integer "package_id"
    t.boolean "divisible"
    t.integer "max_divisor"
    t.integer "default_quantity"
    t.integer "max_versions"
    t.string  "custom_name"
    t.integer "min_quantity"
    t.integer "max_quantity"
    t.float   "version_surcharge"
  end

  create_table "package_option_values", :force => true do |t|
    t.integer "package_id"
    t.integer "product_option_value_id"
    t.boolean "default"
  end

  create_table "packages", :force => true do |t|
    t.string "title"
    t.string "title_image"
    t.string "shortname"
    t.string "subtitle"
  end

  create_table "payments", :force => true do |t|
    t.integer  "order_id",        :limit => 20
    t.string   "type",            :limit => 20
    t.string   "name",            :limit => 100
    t.string   "number",          :limit => 16
    t.float    "amount"
    t.boolean  "approved"
    t.integer  "result",          :limit => 6
    t.string   "pnref"
    t.integer  "auth"
    t.string   "message",         :limit => 50
    t.string   "kind",            :limit => 20
    t.integer  "exp_month",       :limit => 2
    t.integer  "exp_year",        :limit => 4
    t.datetime "created_at"
    t.integer  "design_order_id"
    t.integer  "invoice_id"
    t.float    "amount_paid",                    :default => 0.0
    t.boolean  "captured"
    t.datetime "captured_at"
  end

  add_index "payments", ["order_id", "created_at"], :name => "order_created"

  create_table "pictures", :force => true do |t|
    t.integer "order_id"
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.string  "side"
  end

  create_table "postages", :force => true do |t|
    t.integer "min_quantity"
    t.integer "mailing_option_value_id"
    t.float   "price"
    t.integer "product_id"
  end

  create_table "price_zones", :force => true do |t|
    t.integer "product_id"
    t.integer "max_quantity"
    t.float   "markup"
    t.integer "quantity_increment"
  end

  add_index "price_zones", ["product_id"], :name => "price_zones_product_id_index"
  add_index "price_zones", ["max_quantity"], :name => "price_zones_min_quantity_index"
  add_index "price_zones", ["product_id", "max_quantity"], :name => "product_quantities"

  create_table "product_option_values", :force => true do |t|
    t.string  "product_option_id", :limit => 50
    t.string  "label",             :limit => 50
    t.string  "kind",              :limit => 0
    t.float   "price_per_unit"
    t.integer "unit_quantity",     :limit => 10, :default => 0, :null => false
    t.float   "price_per_sqin"
    t.string  "price_rule",        :limit => 50
    t.string  "customer_label"
    t.text    "tooltip"
    t.float   "weight_multiplier"
    t.float   "makeready"
    t.integer "post_markup"
    t.integer "turnaround_offset"
  end

  create_table "product_options", :force => true do |t|
    t.string  "title",          :limit => 20
    t.float   "setup_price"
    t.boolean "always_visible"
    t.boolean "never_visible"
  end

  create_table "product_pages", :force => true do |t|
    t.string  "name"
    t.string  "title"
    t.text    "description_html"
    t.text    "features_html"
    t.integer "sort_order"
    t.string  "navbar_title"
    t.string  "meta_description"
    t.string  "meta_keywords"
  end

  create_table "products", :force => true do |t|
    t.string  "sku",                    :limit => 10
    t.float   "height"
    t.float   "width"
    t.string  "title",                  :limit => 50
    t.string  "description"
    t.float   "setup_price"
    t.string  "product_code",           :limit => 10
    t.integer "product_page_id"
    t.string  "clarifying_info"
    t.string  "cart_image"
    t.float   "one_sided_layout_price"
    t.float   "two_sided_layout_price"
    t.float   "weight_per_unit",                      :default => 0.0, :null => false
    t.integer "weight_unit_size",                     :default => 50,  :null => false
    t.integer "default_quantity"
    t.boolean "disabled"
    t.integer "sort_order"
    t.float   "one_sided_design_price"
    t.float   "two_sided_design_price"
    t.string  "size_tooltip"
    t.integer "turnaround_offset",                    :default => 0
  end

  create_table "products_product_option_values", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "product_option_value_id"
    t.integer "sort_order"
    t.integer "default",                 :limit => 4, :default => 0, :null => false
    t.integer "max_quantity"
  end

  create_table "proof_methods", :force => true do |t|
    t.string "name", :limit => 50
  end

  create_table "quantities", :force => true do |t|
    t.integer "first", :limit => 10
    t.integer "last",  :limit => 10
    t.integer "step",  :limit => 10
  end

  create_table "roles", :force => true do |t|
    t.string "title", :limit => 64
  end

  create_table "sales_reps", :force => true do |t|
    t.string "name", :limit => 50
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipping_methods", :force => true do |t|
    t.string "name",             :limit => 25
    t.string "ups_service_code"
  end

  create_table "submit_methods", :force => true do |t|
    t.string "name", :limit => 20
  end

  create_table "users", :force => true do |t|
    t.string  "first_name",  :limit => 127
    t.string  "last_name",   :limit => 127
    t.string  "screen_name", :limit => 64
    t.string  "password",    :limit => 40
    t.string  "email"
    t.integer "role_id"
  end

end
