class CustomerMail < ActionMailer::Base
  helper :application
  
  def forgot_password( customer, reset_url )
    @recipients = customer.email
    @from = "service@rocketpostcards.com"
    @subject = "Rocket Postcards: Forgot your password?"
    @body['customer'] = customer
    @body['reset_url'] = reset_url
  end
  
  def order_confirmation( invoice )
    invoice = invoice.reload
    @recipients = invoice.customer.email
    @bcc = "orders@rocketpostcards.com"
    @from = "service@rocketpostcards.com"
    @subject = "Rocket Postcards: Thank You For Your Order"
    @body['invoice'] = invoice
    @body['customer'] = invoice.customer    
  end
  
  def upload_instructions(designer_email, order, upload_url)
    @recipients = designer_email
    @from = "service@rocketpostcards.com"
    @subject = "Rocket Postcards: Artwork Upload Instructions"
    @body['customer'] = order.invoice.customer
    @body['order'] = order
    @body['upload_url'] = upload_url
  end
  
  def custom_job(params)
    #935 - Previously recipient was 'sales@rocketpostcards.com'. Changed by SUHAS-March 3, 2009
    @recipients = 'sales@nomadprinting.com' 
    @from = params[:email]
    @subject = "Custom Job Quote Request"
    @body['params'] = params
  end
  
  def samples_request(params)
    @recipients = 'sales@rocketpostcards.com'
    @from = params[:email]
    @subject = "Samples Request"
    @body['params'] = params
  end
end
