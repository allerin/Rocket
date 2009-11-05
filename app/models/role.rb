class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  def Role.all
    [ :admin, :preflight, :sales, :design, :general, :all ]
  end
  
end
