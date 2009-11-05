module CartPayable
  attr_reader :payment
  
  def add_payment( parameters )
    case parameters[:method]
      when 'credit'
        add_credit_payment(parameters)
      when 'terms'
        add_terms_payment(parameters)
      when 'check'
        add_check_payment(parameters)
    end
  end
  
  def add_credit_payment( parameters )
    payment_type =  case parameters[:credit_type]
                      when 'visa'
                        VisaPayment
                      when 'mastercard'
                        MastercardPayment
                      when 'amex'
                        AmexPayment
                      when 'discover'
                        DiscoverPayment
                    end
    
    @payment = payment_type.new(:number => '4111111111111115',
                                :exp_month => '8',
                                :exp_year => '2012',
                                :name => 'Bob Bobsen')

  end
  
  def add_terms_payment(parameters)
    @payment = TermsPayment.new()
  end
  
  def add_check_payment(parameters)
    @payment = CheckPayment.new(:number => parameters[:check_number], :name => parameters[:check_name])
  end
    
  def authorize_payment
#    return false unless payment
#  
#    payment.amount = total_price
   
  # payment.authorize!(cart.customer)
   
  end
  
end