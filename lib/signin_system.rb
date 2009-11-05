module SigninSystem 
  
  protected
  
  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights  
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?(user)
  #    user.signin != "bob"
  #  end
  def authorize?(user)
     true
  end
  
  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  # 
  #  # don't protect the sign in and the about method
  #  def protect?(action)
  #    if ['action', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
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

    if @current_user and authorize?(@current_user)
      return true
    end

    # store current location so that we can 
    # come back after the user logged in
    store_location
  
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
  end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the sign in screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    redirect_to signin_url
  end  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    redirect_to url_for_redirect(default)
  end
  
  def js_redirect_back_or_default(default)
    render(:update => true, :layout => false) do |page|
      page.redirect_to url_for_redirect(default)
    end
  end
  
  def url_for_redirect(default)
    if session[:return_to].nil? || session[:return_to] == show_customers_url
      default
    else
      return_to = session[:return_to]
      session[:return_to] = nil
      return_to
    end
  end
  

end