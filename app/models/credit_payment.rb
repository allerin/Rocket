class CreditPayment < AbstractPayment
  allow_write( [ :all ] ) { |r| [:admin, :preflight].include?( r ) }
  allow_read( [ :all ] ) { |r| true }
  
  def nice_type
    'Credit Card'
  end  
  
  def authorize!(customer = nil)
  
  
   
   
    return false
  end
  
  def capture!
    self.amount = (self.order or self.design_order).amount_due
    return captured if self.amount <= 0
    gateway = ActiveMerchant::Billing::Base.gateway(:Payflow).new(
          :user     => 'nomaddesign',
          :login    => 'nomaddesign',
          :password => 'webadmin77',
          :partner  => 'verisign'
        ) 
    response = gateway.capture(Money.us_dollar(amount_in_cents), self.pnref)
    
    if response.success?
      self.do_capture_stuff
    end
    return captured
  end
  
  def do_capture_stuff
    self.captured = true
    self.captured_at = Time.now
    self.amount_paid = self.amount
   
    o = (self.order or self.design_order)
    o.reload
    
  end
  
end
