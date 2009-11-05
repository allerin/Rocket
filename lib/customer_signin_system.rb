module CustomerSigninSystem 
  
  protected
  
  def authorize?(user)
     true
  end
  
  def protect?(action)
    true
  end
   
  # signin_required filter. add 
  #
  #   before_filter :signin_required
  #
  # if the controller should be under any rights management. 
  # for finer access control you can overwrite
  #   
  #   def authorize?(user)
  # 
  def signin_required
    if not protect?(action_name)
      return true
    end

    if @current_customer and authorize?(@current_customer)
      return true
    end

    store_location
  
    access_denied
    return false 
  end


  def access_denied
    redirect_to customer_signin_url
    return false
  end  

  def store_location
    session[:return_to] = request.request_uri
  end
  
  def store_location_as(url)
    session[:return_to] = url
  end
  
# move to the last store_location call or to the passed default one
  def url_for_redirect(default)
    if session[:return_to].nil? || session[:return_to] == show_customers_url
      default
    else
      return_to = session[:return_to]
      return_to
    end
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
  
  def redirect_back_or_default(default)
    redirect_to url_for_redirect(default)
    clear_return_to
  end
  
  def js_redirect_back_or_default(default)
    url = url_for_redirect(default)
    render(:update => true, :layout => false) do |page|
      page.redirect_to url
    end
    clear_return_to
  end
  
  def make_signed_in(customer)
    session[:customer] = customer.id
    @current_customer = customer
  end
  

end