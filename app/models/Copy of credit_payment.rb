class CreditPayment < AbstractPayment
  allow_write( [ :all ] ) { |r| [:admin, :preflight].include?( r ) }
  allow_read( [ :all ] ) { |r| true }
  
  def nice_type
    'Credit Card'
  end  
  
  def authorize!(customer = nil)
    creditcard = ActiveMerchant::Billing::CreditCard.new({
      :number => number.to_s,
      :month => exp_month,
      :year => exp_year,
      :first_name => (name.to_s.split.first),
      :last_name => (name.to_s.split[1..-1]).to_a.join(' ')
    })
   
   
    options = (customer and customer.billing_address) ? { :address => customer.billing_address.street_1, 
                                                          :zip => customer.billing_address.zip } : {}
    
    gateway = ActiveMerchant::Billing::Base.gateway(:Payflow).new(
          :user     => 'nomaddesign',
          :login    => 'nomaddesign',
          :password => 'webadmin77',
          :partner  => 'verisign'
        )
      
    response = gateway.authorize(self.amount, creditcard)
   
    self.approved = response.success?
    self.pnref = response.authorization
    self.message = response.message
    self.number = self.number[-4..-1]
    save
   
    return approved
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
    save
    o = (self.order or self.design_order)
    o.reload
    o.save
  end
  
end
