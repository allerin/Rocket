class Order < ActiveRecord::Base
  acts_as_commentable 
  
  belongs_to :invoice
  belongs_to :proof_method
  belongs_to :submit_method
  belongs_to :shipping_method
  belongs_to :address
  belongs_to :product
  
  has_many :product_option_values, :class_name => "OrderProductOptionValue", :dependent => :destroy
  has_many :notes,  :class_name => "OrderNote", :foreign_key => "record_id", :order => "created_at DESC", :dependent => :destroy
  #has_many :order_statuses, :dependent => :destroy
  has_many :payments, :class_name => "AbstractPayment", :dependent => :destroy
  has_many :extra_charges, :dependent => :destroy

  has_one :front_image, :class_name => 'Image', :order => 'images.id DESC', :conditions => "images.side='F'"
  has_one :back_image, :class_name => 'Image', :order => 'images.id DESC', :conditions => "images.side='B'"
  has_many :front_images, :class_name => 'Image', :conditions => "images.side='F'", :dependent => :destroy
  has_many :back_images, :class_name => 'Image', :conditions => "images.side='B'", :dependent => :destroy
  
  has_many  :prepress_comments, :class_name => 'Comment', :conditions => "comments.kind='Prepress'", 
            :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'
  has_many  :press_comments, :class_name => 'Comment', :conditions => "comments.kind='Press'", 
            :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'
  
  has_one :list, :dependent => :destroy
  
  has_many :design_orders
  
  before_create :assign_job_number
  before_create :set_start_date
  
  before_save :set_paid_at
  before_save :set_batch_date, :set_due_date
  
  allow_read( [ :all ] ){ |r| true }
          
  allow_write( [ :batch, :due_date, :status ] ) { |r| [:admin, :preflight].include?( r ) }
  allow_write( [ :sales_rep, :submit_method, :notes, :mailing_quantity, :shipping_method_id, :account_rep,
                :proof_method, :proof_price, :product_code, :product_sku, :submit_method_id, :reseller_id, 
                :product, :quantity, :address_id, :payment_type, :batch_date, :due_batch, :due_date,
                :payment_approved, :run_a, :run_b, 
                :mail_house, :tax_free_verified ] )    { |r| [:admin, :preflight, :sales, :design ].include?( r ) }
  
  
  def self.statuses
    ['Placed', 'On Hold', 'In-House Design', 'Proof Out', 'Passed Preflight', 'Sent to Press', 'Bindery (In House)', 'Bindery (Outsource)', 'Boxed/Completed', 'Shipped', 'Picked Up', 'Design Only', 'Cancelled']
  end
  
  def color_code
    if ink_pov = self.product_option_values.to_a.find { |v| v.title=='Ink' }
      ink = ink_pov.label
      if ink.match(/\/4/)
        return 4
      elsif ink.match(/\/2/)
        return 2
      end
    end
    return 1
  end
  
  def proof_type
    if proof = self.product_option_values.to_a.find { |v| v.title=='Proofing' }
      return proof.label
    end
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
      self.payments << new_payment
    end
    new_payment.order = self
    new_payment.save!
  end
  
  def payment_approved
    payment.approved if payment
  end
  
  def payment_approved=(approved)
    if payment
      payment.approved = approved
    end
  end
  
  def payment
    payments.last
  end
  
  def option_value_for(product_option)
    self.product_option_values.to_a.find { |v| v.title.downcase == product_option.title.downcase }
  end
  
  def options_hash
    return {} if product_option_values.empty?
    @options_hashes ||= {} 
    @options_hashes[product_option_values] ||= 
      ProductOption.find( :all, :include => :product_option_values, 
                          :conditions => product_option_values.collect { |opov| [opov.title, opov.label] }.flatten.insert(0,(["(product_options.title=? AND product_option_values.label=?)"] * product_option_values.length).join(' OR '))).                          
                          inject({}) do |hash, option|
                                        hash[option] = option.product_option_values.first
                                        hash
                                      end
  end

  def soft_options
    options_hash.keys.inject({}) do |hash, option|
      hash[option.title] = options_hash[option].label
      hash
    end
  end
  
  def boxed_products
     return [] unless product
     product.boxes_for(quantity.to_i, options_hash)
  end
  
  def boxes
    boxed_products.collect(&:box)
  end
  
  def boxes_grouped
    groups = boxes.inject({}) do |hash, box|
      hash[box] ||= 0 
      hash[box] += 1
      hash 
    end
    groups.keys.sort_by(&:volume).collect { |box| [box, groups[box]] }.reverse
  end
  
  def art_received? 
    ink = product_option_values.find(:first, :conditions => "title = 'Ink'")
    return true if ink.label == "4/0" and front_art_received 
    return true if front_art_received and back_art_received
  end
  
  def mailing_list_required?
    return true if mailing_quantity and mailing_quantity > 0 and not mailing_list_received?
  end
  
  def one_sided?
    return true if ink = product_option_values.find( :first, :conditions => "title = 'Ink'") and ink.label == "4/0"
  end
  
  def shipping_quantity 
    if mailing_quantity
      return quantity.to_i - mailing_quantity.to_i
    else
      return quantity
    end
  end
  
  
  def amount_paid
    payment ? payment.amount_paid.to_f : 0.0
  end
  
  def amount_due
    self.total.to_f - self.amount_paid
  end
  
  
  def calculate_price
    area = self.product_height * self.product_width
    cost = self.setup_price * area
    
    order_product_option_values.each do | option |
      unless option.title.downcase == "mailing"
        cost += option.setup_price if option.setup_price and not ( value.label.downcase == "none" )
        if option.price_per_unit
          adjusted_cost = option.price_per_unit.to_f / option.unit_quantity.to_f
          option_cost = adjusted_cost * quantity
          cost += option_cost
        else
  				adjusted_cost = option.price_per_sqin / option.unit_quantity
  				option_cost = adjusted_cost * area * quantity
  				cost += option_cost
  			end
      end
    end
  end
  
  def extra_charges_total
    self.extra_charges.inject(0.0) { |t,c| t += c.price.to_f }
  end
  
  def full_job_number
    'R' + self.invoice_id.to_s + '-' + self.job_number.to_s
  end
  
  def self.find_by_full_job_number(job_number)
    if matches = job_number.match(/(\d+)-(\d+)/)
      Order.find(:first, :conditions => ["orders.invoice_id=? AND orders.job_number=?", matches.captures.first, matches.captures.last])
    end
  end
  
  def assign_job_number
    if self.invoice
      self.job_number = Order.count("invoice_id=#{self.invoice_id}") + 1
    end
  end
  
  def reprint?
    true if reprint
  end
  
  def make_reprint
    self.reprint = true
    self.price = 0
    self.shipping_price = 0
    self.proof_price = 0
    self.tax = 0
    self.total = 0
    self.mailing_price = 0
    self.postage_price = 0
  end
  
  def subtotal
    self.price.to_f + self.extra_charges_total
  end

  def self.todays_batch
    day_chars = ['A', 'A', 'B', 'C', 'D', 'E', 'A']
    time = Time.now
    time = (time + (24 - time.hour).hours) if time.hour >= 14
    (time = time + 1.hour until time.wday == 1) if (time.wday == 0 or time.wday == 6)
    day_chars = ['A', 'A', 'B', 'C', 'D', 'E', 'A']
    week = (time.strftime("%U").to_i + 1).to_s
    time.strftime("%y") + 'R' + week + '-' + day_chars[time.wday]
  end
  
  def set_start_date(time = nil, skip_direction = :forward)
    time ||= Time.now
    
    #skip to the next day if the hour is after 14
    time = (time + (24 - time.hour).hours) if time.hour >= 14
    
    #skip forward or back to the next business day, if necessary
    if skip_direction == :forward
      (time = time + 1.hour until time.wday == 1) if (time.wday == 0 or time.wday == 6)
    else
      (time = time - 1.hour until time.wday == 5 and time.hour < 14) if (time.wday == 0 or time.wday == 6)
    end
    
    self['start_date'] = time
    set_batch_date
    set_due_date
    time
  end
  
  def set_batch_date
    time = (self.start_date || set_start_date)
    
    #adjust for turnaround time
    turnaround_offset = turnaround - 2
    time = time.offset_business_days(turnaround_offset)
    
    #adjust for product turnarounf offset
    time = time.offset_business_days(self.product_turnaround_offset)
    
    #adjust for other options
    option_offset = self.product_option_values.collect(&:turnaround_offset).sort_by(&:to_i).first.to_i
    time = time.offset_business_days(option_offset)
    
    self['batch_date'] = time
    set_batch_code
    time
  end
  
  def set_batch_code
    self['batch'] = self['batch_date'].to_batch_code
  end
  
  def set_due_date
    return false unless self.start_date
    self['due_date'] = self.start_date.offset_business_days(turnaround) 
  end
  
  def bump_dates(offset)
    return false unless self['start_date']
    direction = (offset > 0 ? :forward : :reverse)
    
    set_start_date((self.start_date + offset.days), direction)
    set_batch_date
    set_batch_code
    set_due_date
    self.start_date
  end 
  
  def set_paid_at
    if not self.paid_at and self.total.to_f > 0 and self.amount_due <= 0
      self.paid_at = Time.now
    end
  end
  
  def turnaround
    return 3 unless pov = product_option_values.to_a.find { |p| p.title.to_s.downcase == 'turnaround' }
    #product_option_values.find(:first, :conditions => "order_product_option_values.title='Turnaround'")
    pov.label.to_i
  end
  
  def create_folder
    Dir.mkdir(RAILS_ROOT + "/jobs") unless File.directory?(RAILS_ROOT + "/jobs")
    job_dir = RAILS_ROOT + "/jobs/#{self.full_job_number}"
    Dir.mkdir(job_dir) unless File.directory?(job_dir)
    File.open(job_dir+"/list.txt", 'w+') { |f| f.write(self.list.data) } if self.list
    ['front', 'back'].each do |side|
      self.send("#{side}_images".to_sym).each_with_index do |image, i|
        File.open(job_dir+"/#{side}_#{i}#{File.extname(image.filename)}", 'w+') { |f| f.write(image[image.data_field]) }
      end
    end
    
  end
end
