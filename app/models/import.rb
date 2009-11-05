require 'order'

class Import < ActiveRecord::Base
  
  def self.run
    imports = self.find(:all)
    imports.each {|import| import.create_order; print(".") }
    return "Imported #{imports.length} Orders"
  end
  
  def create_order
    unless self.Product_Code1.empty?
      order = Order.new

      invoice = get_invoice
      order.invoice = invoice
      
      product = Product.find(:first, :conditions=>["product_code=?", self.Product_Code1])
      return unless product
      
      order.product = product
      
      product.options_map.each_pair do |key, values|
        if values.length == 1
          value = ProductOptionValue.find_by_label(values[0].to_s)
        elsif key == :ink
          self.ColorType = 4 unless ["1", "4"].include?(self.ColorType)
          value = ProductOptionValue.find_by_label("#{self.ColorType}/1")
        end
        order.product_option_values << value if value
      end
      
      order.quantity = self.Product_Quantity1
      order.price = self.Price_subtotal

      order.address = invoice.customer.shipping_address
      order.shipping_method = ShippingMethod.find(:first, :conditions=>["name=?", self.Shipping_Method])
      order.shipping_price = self.Shipping_subtotal

      order.proof_method = ProofMethod.find(:first, :conditions=>["name=?", self.ProofMethod])
      order.proof_price = self.ProofTotal
      order.tax = self.CA_Sales_Tax
      order.total = self.Order_Total
    
      order.submit_method = SubmitMethod.find(:first, :conditions=>["name=?", self.SubmitMethod])      
      order.status = self.Status
      order.batch = self.Batch_Num
      order.save      
      
      payment = nil
      if self.Billing_Method.downcase == "cash"
        payment = CashPayment.new
      elsif self.Billing_Method.downcase == "check"
        payment = CheckPayment.new
        payment.name = self.Checkholder
        payment.number = self.Check_Pound || self.Check_Num
      elsif ["mastercard", "visa", "american express", "discover"].include?(self.Billing_Method.downcase)
        payment = CreditPayment.new
        payment.result = 1
        payment.message = self.auth_result
        payment.auth = self.auth_code
        payment.pnref = self.pn_ref
      elsif self.Billing_Method.downcase == "trade"
        payment = TradePayment.new
      elsif self.Billing_Method.downcase == "terms"
        payment = TermsPayment.new
      end
      
      if payment
        payment.order = order
        payment.amount = self.Order_Total
        payment.approved = 1
        payment.save
      end

      unless self.Special_Instructions.empty?
        order.notes.create(:content => "Special Instructions: #{self.Special_Instructions}")
      end
      
      unless self.PrePress_Comments.empty?
        order.notes.create(:content => "Prepress Comment: #{self.PrePress_Comments}")
      end
      
      unless self.Press_Comments.empty?
        order.notes.create(:content => "Press Comment: #{self.Press_Comments}")
      end

      return order
    end
  end
  
  def get_invoice
    customer = get_customer
    invoice = Invoice.new
    
    invoice.customer = customer
    invoice.address = customer.billing_address
    
    invoice.save
    return invoice
  end
  
  def get_customer
    customer = Customer.find(:first, :conditions=>["email=?", self.B_email])
    customer ||= Customer.new
    
    customer.first_name = self.B_First_Name
    customer.last_name = self.B_Last_Name
    customer.company = self.B_Company
    customer.email = self.B_email
    customer.phone = self.B_Phone
    customer.fax = self.B_Fax
    customer.reseller_id = self.CA_Resale_Num
    customer.kind = self.Kind
    
    customer.save
    
    address = {}
    address[:first_name] = self.B_First_Name
    address[:last_name] = self.B_Last_Name
    address[:company] = self.B_Company
    address[:phone] = self.B_Phone
    address[:street_1] = self.B_Address
    address[:city] = self.B_City
    address[:state] = self.B_State
    address[:zip] = self.B_ZIP
    address[:country] = self.B_Country
    
    billing_address = get_address(customer, address)
    
    address = {}
    address[:first_name] = self.S_First_Name
    address[:last_name] = self.S_Last_Name
    address[:company] = self.S_Company
    address[:phone] = self.S_Phone
    address[:street_1] = self.S_Address
    address[:city] = self.S_City
    address[:state] = self.S_State
    address[:zip] = self.S_ZIP
    address[:country] = self.S_Country
    
    shipping_address = get_address(customer, address)
    
    customer.billing_address = billing_address
    customer.shipping_address = shipping_address
    customer.save
    
    return customer
  end
  
  def get_address(customer, params)
    address = Address.find( :first, :conditions=>[ "first_name=? AND last_name=? AND 
                                                    street_1=? AND city=? AND state=?", 
                                                    params[:first_name], params[:last_name],
                                                    params[:street_1], params[:city], params[:state] ] )
                                    
    address ||= Address.new( :label => "Address #{customer.addresses.count + 1}", 
                             :customer => customer )
                       
    address.update_attributes(params)
    address.save
    return address
  end
  
end
