class Invoice < ActiveRecord::Base
  acts_as_commentable
  
  belongs_to :customer
  belongs_to :address
  
  has_many :orders, :order => "created_at ASC"
  has_many :design_orders, :order => "created_at ASC"

  has_many :notes,  :class_name => "InvoiceNote", :foreign_key => "record_id"
  
  allow_read( :all ){ |r| true }
  allow_write( :all ){ |r| false }
  
  allow_write( [ :address_id, :address ] ){ |r| [:admin, :preflight, :sales, :design].include?( r ) }
  
  def order_list
    orders.collect {|order| { :id => order.id,
                             :job_number => ('R' + self.id.to_s + '-' + order.job_number.to_s),
                             :product => (order.product.title if order.product), 
                             :quantity => order.quantity,
                             :batch => order.batch,
                             :run => "A:#{order.run_a} B:#{order.run_b}",
                             :total => order.total} }
  end
  
  def design_list
    design_orders.collect { |design| 
      { :id => design.id,
        :job_number => design.full_job_number,
        :name => design.custom_name,
        :total => design.total
      } }
  end
  
  def total
    t = self.orders.inject(0){ |tot, order| tot += order.total || 0 }
    t += self.design_orders.inject(0){ |tot, design| tot += design.total || 0}
  end
  
  def printing_total
    self.orders.inject(0){ |tot, order| tot += order.price || 0 }
  end
  
  def mailing_total
    self.orders.inject(0){ |tot, order| tot += (order.mailing_price || 0) }
  end
  
  def postage_total
    self.orders.inject(0){ |tot, order| tot += (order.postage_price || 0) }
  end
    
  def design_total
    self.design_orders.inject(0){ |tot, design| tot+= design.price }
  end
  
  def shipping_total
    self.orders.inject(0){ |tot, order| tot+= (order.shipping_price || 0) }
  end
  
  def tax_total
    t = self.orders.inject(0){ |tot, order| tot+= (order.tax || 0 ) }
    t += self.design_orders.inject(0){ |tot, design| tot+= (design.tax || 0) }
  end
  
end
