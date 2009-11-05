module Admin::AdminHelper
  
  def account_reps
    Customer.find(:all, :select => "DISTINCT customers.account_rep").collect(&:account_rep).compact << "Other" << ""
  end
end
