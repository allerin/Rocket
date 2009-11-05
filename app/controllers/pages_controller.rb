class PagesController < ApplicationController
  
  layout 'customer'
  
  def show
    render :template => 'pages/' + params[:page]
  end
    
end
