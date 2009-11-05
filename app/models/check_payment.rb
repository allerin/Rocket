class CheckPayment < AbstractPayment
  allow_write( [ :all ] ) { |r| [:admin, :preflight].include?( r ) }
  allow_read( [ :all ] ) { |r| true }
  
  def nice_type
    'Check'
  end
  
  def authorize!(customer = nil)
    self.approved = true
  end
  
end
