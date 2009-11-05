class Admin::AdminController < ApplicationController
  include ProductsHelper
  include SigninSystem
  attr_reader :current_user
  before_filter :assign_current_user
  helper :TModelSecurity
  
  def index
    redirect_to show_customers_url
  end
  
  def assign_current_user
    session[:user] ||= 0
    user = User.find( :first, :conditions => ["id = ?", session[:user]] )
    @current_user = user
    return true
  end
  
  
end
