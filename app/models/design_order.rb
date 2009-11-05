class DesignOrder < ActiveRecord::Base
  has_many :design_option_values, :class_name => "DesignOrderOptionValue"
  belongs_to :invoice
  belongs_to :order
  belongs_to :product
  belongs_to :address
  before_create :assign_job_number, :assign_status
  has_many :payments, :class_name => "AbstractPayment", :dependent => :destroy
  before_save :set_paid_at
  
  acts_as_tree
  
  allow_read( [ :all ] ){ |r| true }
  allow_write( [ :all ] ){ |r| true }
  
  def self.statuses
    ['Placed', 'In Progress', 'Completed']
  end
  
  def payment_type
    payments.last.class.to_s if payments.last
  end
  
  def payment_type=(p_type)
    return false if payment.kind_of?(p_type.constantize)
    if old = payments.last
      new_payment = p_type.constantize.new(old.attributes)
    else
      new_payment = p_type.constantize.new
    end
    new_payment.design_order = self
    new_payment.save!
  end
  
  def payment
    payments.last
  end
  
  def payment_approved
    payment.approved if payment
  end
  
  def payment_approved=(approved)
    if payment
      payment.approved = approved
    end
  end
  
  def amount_paid
    payment ? payment.amount_paid.to_f : 0.0
  end
  
  def amount_due
    self.total.to_f - self.amount_paid
  end
  
  def for_product_title
    if self.order
      return ( order.custom_name || order.product_title )
    elsif self.product
      return product.title
    elsif self.parent
      return parent.for_product_title
    end
  end
  
  def assign_job_number
    if self.invoice
      self.job_number = (self.new_record? ? (DesignOrder.count("invoice_id=#{self.invoice_id}") + 1) : 
                                            self.invoice.design_orders.index(self) + 1)
      assign_full_job_number
    end
  end
  
  def assign_full_job_number
    self.full_job_number = 'RD' + self.invoice_id.to_s + '-' + self.job_number.to_s
  end
  
  def print_job_number
    if self.order
      order.full_job_number
    end
  end
  
  def option_value_for(option)
    self.design_option_values.to_a.find { |v| v.option_label.downcase == option.label.downcase }
  end
  
  def self.designers
    DesignOrder.find(:all, :select => "DISTINCT designer", :order => "designer ASC").collect(&:designer)
  end
  
  def assign_status
    self.status ||= 'Placed'
  end
  
  
  def set_paid_at
    if not self.paid_at and self.total.to_f > 0 and self.amount_due <= 0
      self.paid_at = Time.now
    end
  end
  
end
