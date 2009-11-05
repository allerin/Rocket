ActionController::Routing::Routes.draw do |map|
  
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Product Routes
  map.home '/', :controller => 'products', :action => 'home'
  map.products    '/services', :controller => 'products', :action => 'index'
  map.custom_design '/services/design', :controller => 'products', :action => 'design'
  map.mailing_services '/services/mailing', :controller => 'products', :action => 'mailing'
  map.design_instructions '/services/design_instructions', :controller => 'products', :action => 'design_instructions'
  map.custom_quote  '/services/custom-quote', :controller => 'products', :action => 'custom_quote'
  map.request_samples  '/services/request-samples', :controller => 'products', :action => 'request_samples'
  map.show_product  '/services/:name', :controller => 'products', :action => 'show'
  
  map.faq '/faq', :controller => 'pages', :action => 'show', :page => 'faq'
  map.contactus '/contactus', :controller => 'pages', :action => 'show', :page => 'contactus'
  map.about '/about', :controller => 'pages', :action => 'show', :page => 'about'
  map.artrequirements '/artrequirements', :controller => 'pages', :action => 'show', :page => 'artrequirements'
  map.templates '/templates', :controller => 'pages', :action => 'show', :page => 'templates'
  map.designer_upload '/upload/designer/:order_id', :controller => 'upload', :action => 'designer'
  map.upload_file '/upload/file', :controller => 'upload', :action => 'upload'
  map.refresh_order_upload '/upload/refresh/:order_id', :controller => 'upload', :action => 'refresh'
  map.upload    '/upload', :controller => 'upload', :action => 'index'
  map.upload_progress '/upload/progress', :controller => 'upload', :action => 'progress'
  map.upload_finished '/upload/finished/:order_id', :action => 'finished', :controller => 'upload'
  map.upload_aa    '/upload/aa', :controller => 'upload', :action => 'aa'
  map.show_upload '/upload/show/:order_id', :action => 'show', :controller => 'upload'
  map.show_page '/pages/:page', :controller => 'pages', :action => 'show'  
  
  map.marketingtips '/marketingtips', :controller => 'pages', :action => 'show', :page => 'marketingtips'
  map.postcardtips '/postcardtips', :controller => 'pages', :action => 'show', :page => 'postcardtips'
  
  map.add_product '/cart/products/add', :controller => 'checkout', :action => 'add_to_cart'
  map.add_package '/cart/packages/add/:package_id', :controller => 'checkout', :action => 'add_package'
  
  
  #packages routes
  map.package_intro '/packages/:page', :controller => 'packages', :action => 'intro'
  map.package_show '/packages/show/:shortname', :controller => 'packages', :action => 'show'
  map.calculate_package_price '/packages/calculate/:shortname', :controller => 'packages', :action => 'calculate_price'
  
  
  map.admin_list_packages '/admin/packages', :controller => 'admin/packages', :action => 'list'
  map.admin_edit_package '/admin/packages/edit/:package_id', :controller => 'admin/packages', :action => 'edit'
  map.admin_new_package '/admin/packages/edit', :controller => 'admin/packages', :action => 'edit'
  map.admin_save_package  '/admin/packages/save', :controller => 'admin/packages', :action => 'save'
  map.add_product_to_package '/admin/packages/add_product/:package_id', :controller => 'admin/packages', :action => 'add_product'
  map.remove_product_from_package '/admin/packages/remove_product/:package_id/:package_item_id', 
                                  :controller => 'admin/packages', :action => 'remove_product'
  map.add_package_option '/admin/packages/add_option/:package_id', :controller => 'admin/packages', :action => 'add_option'
  map.admin_remove_package '/admin/packages/remove/:package_id', :controller => 'admin/packages', :action => 'remove' 
  map.add_package_item_option '/admin/packages/add_item_option/:item_id', :controller => 'admin/packages', :action => 'add_item_option'
  
  #coupons routes
  map.admin_list_coupons  '/admin/coupons', :controller => 'admin/coupons', :action => 'list'
  map.admin_edit_coupon   '/admin/coupons/edit/:id', :controller => 'admin/coupons', :action => 'edit'
  map.admin_new_coupon    '/admin/coupons/new', :controller => 'admin/coupons', :action => 'edit'
  map.admin_save_coupon   '/admin/coupons/save', :controller => 'admin/coupons', :action => 'save'
  map.admin_remove_coupon '/admin/coupons/remove/:id', :controller => 'admin/coupons', :action => 'remove'
  map.admin_remove_coupon_assignment '/admin/coupons/remove_assignment/:id', 
                                      :controller => 'admin/coupons', :action => 'remove_assignment'
  
  # Checkout/Profile Routes
  map.profile '/account/profile/', :controller => 'account', :action => 'profile'
  map.confirm_updated '/account/confirm_updated/', :controller => 'account', :action => 'confirm_updated'
  
  map.customer_signin '/account/signin/', :controller => 'account', :action => 'signin'
  map.customer_signin_modal '/account/signin/modal/', :controller => 'account', :action => 'signin_modal'
  map.customer_signout '/account/signout/', :controller => 'account', :action => 'signout'
  
  
  map.review_cart   '/cart/review',         :controller => 'checkout', :action => 'review_cart'
  map.shipping_info '/cart/shipping_info', :controller => 'checkout', :action => 'shipping_info'
  
  map.apply_coupon  '/cart/apply_coupon', :controller => 'checkout', :action => 'apply_coupon'
  
  # Customer Routes
  map.show_customers     '/customers/show', :controller => "admin/customers",
                                          :action => "show"
                                             
  map.show_all_customers '/customers/show/all', :controller => "admin/customers",
                                                :action => "show",
                                                :all => "true",
                                                :view => "list"
                                             
  map.find_customers   '/customers/show/find/:search', :controller => "admin/customers",
                                                       :action => "show",
                                                       :search => nil
                                                          
  map.view_customer    '/customers/show/:id', :controller => "admin/customers",
                                              :action => "show"
                                              
  map.search_customers '/customers/show/:key/:value', :controller => "admin/orders",
                                                      :action => "show"
                                                  
  map.add_customer_comment '/customers/comments/add/:customer_id', :controller => 'admin/customers', :action => 'add_comment'
                                        

  map.update_customer_field '/customers/update_field/:customer_id', :controller => 'admin/customers', 
                              :action => 'update_customer_field' 
  map.update_customer_address '/customers/update_address_field/:customer_id', :controller => 'admin/customers', 
                              :action => 'update_address_field' 
  # Added by SUHAS - October 1, 2008
  map.new_customer_address '/customers/new_customer_address/:customer_id', :controller => 'admin/customers',
                              :action => 'new_customer_address'
  map.update_customer_existing_address '/customers/update_customer_existing_address/:address_id',
                            :controller => 'admin/customers', :action => 'update_customers_address'

  # Invoice Routes
  map.show_invoices     '/invoices/show', :controller => "admin/invoices",
                                        :action => "show"
                                             
  map.show_all_invoices '/invoices/show/all', :controller => "admin/invoices",
                                              :action => "show",
                                              :all => "true",
                                                :view => "list"

  map.search_invoices   '/invoices/show/:key/:value', :controller => "admin/invoices",
                                                    :action => "show"
                                        
  map.view_invoice      '/invoices/:value', :controller => "admin/invoices",
                                            :action => "show",
                                            :key => "invoices.id"                                   
  
  map.create_invoice    '/invoices/create/:customer_id', :controller => "admin/invoices", 
                            :action => "create", :view => 'detail'

  map.destroy_invoice '/invoices/destroy/:id', :controller => 'admin/invoices', :action => 'destroy'
  
  map.add_invoice_comment '/invoices/comments/add/:invoice_id', :controller => 'admin/invoices', :action => 'add_comment'
  
  map.mark_as_sent '/invoices/mark_as_sent/:id', :controller => 'admin/invoices', :action => 'mark_as_sent'
  
  map.print_invoice '/invoices/print/:id', :controller => 'admin/invoices', :action => 'print'
  
  # Order Routes                                    
  
  map.list_orders   '/orders', :controller => 'admin/orders', :action => 'advanced_search'
  map.list_design_orders '/designs', :controller => 'admin/orders', :action => 'design_search'
  
  map.show_order    '/orders/:id', :controller => 'admin/orders', :action => 'show'
  
  map.create_order  '/orders/create/:invoice_id', :controller => "admin/orders", 
                            :action => "create", :view => 'detail'

  map.reorder       '/orders/:id/reorder', :controller => 'admin/orders', :action => 'reorder'
  map.reprint       '/orders/:id/reprint', :controller => 'admin/orders', :action => 'reprint'
  
  map.view_design_order '/design_orders', :controller => 'admin/orders', :action => 'show_design'
  
  map.add_order_comment '/orders/comments/add/:order_id', :controller => 'admin/orders', :action => 'add_comment'
  map.show_order_image '/reports/show_me/:id', :controller => 'admin/reports', :action => 'show_me'
  # Added by Suhas - Sept 24, 2008
  map.report_paid_date '/reports/report_paid_date', :controller => 'admin/reports', :action => 'update_paid_date'
               
  map.show_order_image '/orders/show_image/:id/:size.jpg', :controller => 'admin/orders', :action => 'show_image'
  map.image_original '/orders/images/original/:id', :controller => 'admin/orders', :action => 'image_original'
  map.download_list '/orders/list/download/:id', :controller => 'admin/orders', :action => 'download_list'
  
  map.admin_upload '/orders/images/upload/:order_id', :controller => 'admin/orders', :action => 'upload'
  map.remove_image '/orders/images/remove/:id', :controller => 'admin/orders', :action => 'remove_image'
  
  map.advanced_order_search '/orders/search/advanced', :controller => 'admin/orders', :action => 'advanced_search'
  
  map.bump_order '/orders/bump/:id', :controller => 'admin/orders', :action => 'bump'
  
  map.change_address  '/orders/change_address/:address_type/:order_id', :controller => "admin/orders", 
                        :action => "change_address"   
  map.order_paid_now '/orders/paid_now/:id', :controller => 'admin/orders', :action => 'paid_now'
  map.invoice_sent_now '/orders/invoiced_now/:id', :controller => 'admin/orders', :action => 'invoiced_now'
  
  map.design_commission_paid_now '/designs/commission_paid_now/:id', :controller => 'admin/orders', 
                                  :action => 'design_paid', :commission => true
  map.design_paid_now '/designs/paid_now/:id', :controller => 'admin/orders', :action => 'design_paid'
  map.capture_payment '/orders/payments/capture/:id', :controller => 'admin/orders', :action => 'capture_payment'
  
  map.update_press_notes '/orders/notes/press/:id', :controller => 'admin/orders', :action => 'update_press_notes'
  map.create_folder '/orders/create_folder/:id', :controller => 'admin/orders', :action => 'create_folder'
  map.update_runs '/orders/runs/:id', :controller => 'admin/orders', :action => 'update_runs'
  map.update_address '/orders/address/:order_id/:id', :controller => 'admin/orders', :action => 'update_address'
  #report routes

  map.with_options(:controller => 'admin/reports') do |map|
    map.reports   '/reports', :action => 'list'
    map.report_form '/reports/form/:form', :action => 'form'
    map.report_pickup_list '/reports/list/pickup', :action => 'pickup_list'
    map.report_pickup_make_completed '/reports/pickup/make_completed', :action => 'pickup_make_completed'
    map.report_shipping_list '/reports/list/shipping', :action => 'shipping_list'
    map.report_make_shipped '/reports/shipping/make_shipped', :action => 'shipping_make_shipped'
    map.report_ship_export  '/reports/shipping/export', :action => 'shipping_export'
    map.report_run_list     '/reports/list/run', :action => 'run_list'
    map.report_add_comment '/reports/add_press_comment', :action => 'add_press_comment'
    map.report_change_run   '/reports/change_run', :action => 'change_run'
    map.report_run_export   '/reports/run/export', :action => 'run_export'
    map.report_status_list  '/reports/list/status', :action => 'status_list'
    map.report_change_status '/reports/change_status', :action => 'change_status'
    map.report_tax_list     '/reports/list/tax', :action => 'tax_list'
    map.report_terms_list   '/reports/list/terms', :action => 'terms_list'
    map.report_rep_list     '/reports/list/rep', :action => 'rep_list'
    map.report_payment_list '/reports/list/payment', :action => 'payment_list'
    map.report_design_list  '/reports/list/design', :action => 'design_list'
    map.report_capture_list '/reports/list/capture', :action => 'capture_list'
    map.report_capture_payment  '/reports/capture', :action => 'capture_payment'
  end

 # Product Routes
  map.sku_autocomplete  '/admin/products/auto_complete_for_sku', :controller => 'admin/products', :action => 'autocomplete_for_sku'
 
  map.show_products '/admin/products/show', :controller => 'admin/products', :action => 'show'
                                      
  # Users
  map.show_users    '/users/show', :controller => 'admin/user', :action => 'show'
  map.view_user     '/users/show/:id', :controller => 'admin/user', :action => 'show'
  map.edit_user     '/users/edit/:id', :controller => 'admin/user', :action => 'edit'
  map.destroy_user  '/users/destroy/:id', :controller => 'admin/user', :action => 'destroy'
  
  map.signin        'signin', :controller => 'admin/user', :action => 'signin'
  
  map.signout       'signout', :controller => 'admin/user', :action => 'signout'                                                             
                                                
  # Default Route
  
  map.admin_home '/admin', :controller => "admin/orders", 
                           :action => "advanced_search"
  
  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
