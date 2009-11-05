class AbstractPayment < ActiveRecord::Base
  set_table_name "payments"
  belongs_to :order
  belongs_to :design_order
  

  
  def nice_type
    ''
  end
  
  def nice_exp
    return '' unless exp_month and exp_year
    exp_month.to_s + '/' + exp_year.to_s
  end
  
  def approved?
    self['approved']
  end  
  
  def authorize!
    raise "not implemented."
  end
  
  def amount_in_cents
    amount.to_f * 100
  end
end
