class TermsPayment < AbstractPayment
  allow_write( [ :all ] ) { |r| [:admin, :preflight].include?( r ) }
  allow_read( [ :all ] ) { |r| true }
  
  def nice_type
    'Free'
  end
    
  def authorize!(customer)
    self.approved = true
  end
  
end