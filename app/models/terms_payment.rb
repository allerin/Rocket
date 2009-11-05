class TermsPayment < AbstractPayment
  allow_write( [ :all ] ) { |r| [:admin, :preflight].include?( r ) }
  allow_read( [ :all ] ) { |r| true }
  
  def nice_type
    'Terms'
  end
  
  def credit_used
    self.approved ? (amount.to_f - amount_paid.to_f) : 0
  end
  
  def authorize!(customer)
    self.approved = (customer.remaining_credit >= amount.to_f)
  end
  
end
