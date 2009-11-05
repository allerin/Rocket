class Customer < ActiveRecord::Base
  has_many :addresses
  has_many :invoices
  acts_as_commentable
  
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "shipping_address_id"
  belongs_to :billing_address, :class_name => "Address", :foreign_key => "billing_address_id"
  
  allow_read( :all ){ |r| true }
  allow_write( :all ){ |r| true }
  #allow_write(:reseller_on_file) { |r| [:admin].include?(r) }
    
  def self.authenticate(email, password)
    matches = self.find( :all, :conditions => ["email = ?", email ] )
    matches.each { |customer| return customer if customer.password?( password ) }
    return nil
  end
  
  def password=(str)
    unless str.nil? || str.empty?
      password = Digest::SHA1.hexdigest( str + "nomad" )
      write_attribute( "password", password )
    end
    return str
  end
  
  def password?( str )
    chk_pass = Digest::SHA1.hexdigest( str + "nomad" )
    the_pass = self["password"]
    return chk_pass == the_pass
  end
  
  # For when we send out emails to designers with instructions for uploading images for their clients' orders.
  def upload_auth_string
    Digest::SHA1.hexdigest( self.email + "nomad" ) 
  end
  
  def remaining_credit
    self.terms_credit.to_f - terms_payments.inject(0.0) { |total_credit, payment| total_credit += payment.credit_used }
  end
  
  def terms_payments
    TermsPayment.find(:all, :include => {:order => :invoice }, :conditions => ["invoices.customer_id=?",self.id])
  end
  
  def name
    first_name + ' ' + last_name
  end
  
  def self.issues
    Customer.find(:all, :select => "issues", :group => "issues").collect(&:issues)
  end
  
  def self.account_reps
    (Customer.find(:all, :select => "account_rep", :group => "account_rep").collect(&:account_rep) + 
      Order.find(:all, :select => "account_rep", :group => "account_rep").collect(&:account_rep)).uniq
  end
  
  def password_clear; ''; end
  
  alias :password_clear= :password=

end
