class Admin::UserController < Admin::AdminController
  
  layout 'main'
  before_filter :signin_required, :only => [:show, :edit, :destroy]
  
  access_control [ :show ] => 'admin'
  
  def show
    
    @views = {'list' => 10, 'detail' => 1}
    
		@view = if @views.keys.include?(params[:view])
		          session[:view] = params[:view]
		        elsif @views.keys.include?(session[:view])
		          session[:view]
		        else
		          @views.keys.first
		        end
		
		per_page = @views[@view]
		
		user_id =  if params[:id]
		              session[:user_id] = params[:id]
		            else
		              session[:user_id]
		            end
  
		sort =  if params[:sort]
		          session[:users_sort] = params[:sort]
		        elsif session[:users_sort]
		          session[:users_sort]
		        else
		          'users.first_name'
		        end
		        
    if params[:page]
			session[:users_page] = params[:page]
		elsif session[:users_page]
			params[:page] = session[:users_page]
		end	        

    search_conditions = if params[:all]
                          session[:quicksearch], session[:users_page], session[:user_id] = nil
  	                      "1"
                    		elsif user_id and @view == 'detail'
                          ["users.id = ?", user_id]  
                    		end
                    		
    pager_params = {
		  :order_by => sort,
		  :per_page => per_page,
      :select => "users.*"		
    }

		pager_params[:conditions] = search_conditions if search_conditions

 		@pages, @records = paginate :users, pager_params

		@loading = ""
		@complete = ""
		
		@roles = Role.find(:all)
				
		if request.xhr?
			render :partial => 'show' 
		end
    
  end
  
  def edit
    
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = User.new
    end
    
    @user.screen_name = params[:user][:screen_name]
    @user.first_name = params[:user][:first_name]
    @user.last_name = params[:user][:last_name]
    @user.email = params[:user][:email]
    @user.role_id = params[:user][:role_id]
    
    if params[:password] and params[:password].length > 0
      if params[:password] == params[:password_confirmation]
        @user.password = params[:password]
      else
        render_text "<p>The password fields did not match, so the user's password was not changed."
        return
      end
    end
    
    if @user.save
      flash[:notice] = "User record has been updated"
    else
      flash[:notice] = "There was an error updating the user"
    end
    
    if request.xhr?
      show
    else
      redirect_to :action => 'show'
    end
    
  end
  
  def remove
    @user = User.find(params[:id])

  end
  
  def destroy
    User.destroy(params[:id])
    
    show
  end
  
  def new
    user = User.new
    user.role = Role.find(:first)
    
    @pages = []
    @records = [ User.new ]
    @roles = Role.find(:all)
    @view = 'detail'
    
    if request.xhr?
      render :partial => "show"
    else
      render :action => 'show'
    end
    
  end
  
  def signin
    if @current_user.kind_of? User
      return
    end

    case request.method
      when :post
      user = User.authenticate(params[:signin], params[:password])
      
      if user
        user = User.find(user)
        uid = user.id        
        session[:user] = uid
        redirect_back_or_default show_customers_url
        return
      else
        flash.now[:error]  = render_to_string( :inline => "<p>We weren't able to find that user and password.</p>" )
        @signin = params[:signin]
    end
  end
    

    
  end
  
  def signout
    session[:user] = 0
    session[:return_to] = nil
    redirect_to signin_url
    return
  end
  
end
