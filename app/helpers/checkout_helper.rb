module CheckoutHelper
  include ProductsHelper

  def safe_upload_url(order)
    return designer_upload_url(:customer_id => order.invoice.customer_id, :auth => order.invoice.customer.upload_auth_string )
  end
end
