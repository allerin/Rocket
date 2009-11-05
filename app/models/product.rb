# (c) Copyright 2005 Trigger Consulting. All Rights Reserved.

# Class for products.
#
# _Associations_:
# has_and_belongs_to_many:: ProductOption
# has_many:: Quantity
class Product < ActiveRecord::Base
	has_many :products_product_option_values, :order => "'default' DESC, 'sort_order' ASC"  
	#has_many :product_option_values, :through => :products_product_option_values, :source => :product_option_value
	has_and_belongs_to_many :product_option_values, :join_table => 'products_product_option_values', :order => "`default` DESC, `sort_order` ASC"

	has_many :price_zones, :order => 'max_quantity ASC'
	belongs_to :product_page
	has_many :boxed_products
	has_many :postages
	has_many :make_readies
	
	has_many :coupon_assignments
	has_many :coupons, :through => :coupon_assignments
	
	allow_read(:all){ |r| true }
	allow_write(:all){ |r| r == :admin }
	
	attr_accessor :price_explanations
	
	def coupon_applicable?(coupon)
	  self.coupons.include?(coupon)
	end
	

	def design_price( design_hash )
	  
	  cost = 0
	  if design_hash[:job_number]
	    cost += 10
	  else
	    if design_hash[:design_options][:sides] 
	      if design_hash[:design_options][:sides] == "1"
	        cost += self.one_sided_layout_price
	      else 
	        cost += self.two_sided_layout_price
	      end
	    else
	      if self.one_sided_layout_price and self.one_sided_layout_price > 0
	        cost += self.one_sided_layout_price
	      elsif self.two_sided_layout_price and self.two_sided_layout_price > 0
	        cost += self.two_sided_layout_price
	      else
	        raise "There is no layout pricing for this product (id = #{self.id})"
	      end
	    end  
	  end
	  
	  raw_options = DesignOption.soft_to_raw( design_hash[:design_options] )
	  raw_options.each do | option, value |
	    cost += value.setup_price if value.setup_price and not option.label == "proof"
	  end
	  logger.debug "cost: #{cost}"
	  return cost
	end
	
	def product_options
	  return [] if new_record?
  	ProductOption.find( :all,
                        :select => 'DISTINCT product_options.*',
                        :joins => ' LEFT JOIN product_option_values on product_options.id = product_option_values.product_option_id LEFT JOIN products_product_option_values ON product_option_values.id=products_product_option_values.product_option_value_id ',
                        :conditions => "products_product_option_values.product_id=#{self.id}",
                        :order => 'product_options.id ASC')
  end
	
	def product_options_with_multiple_choices
	  return [] if new_record?    
	  ProductOption.find( :all,
	                      :select => 'DISTINCT product_options.*',
	                      :joins => ' LEFT JOIN product_option_values on product_options.id = product_option_values.product_option_id LEFT JOIN products_product_option_values ON product_option_values.id=products_product_option_values.product_option_value_id ',
	                      :conditions => "products_product_option_values.product_id=#{self.id} AND ( product_options.always_visible = 1 OR (SELECT count(*) from products_product_option_values LEFT JOIN product_option_values on products_product_option_values.product_option_value_id = product_option_values.id LEFT JOIN product_options as subquery_product_options on product_option_values.product_option_id = subquery_product_options.id WHERE products_product_option_values.product_id=#{self.id} and subquery_product_options.id=product_options.id) > 1)",
	                      :order => 'product_options.id ASC' )	  
	end
	
  def product_options_with_one_choice
    return [] if new_record?
	  ProductOption.find( :all,
	                      :select => 'DISTINCT product_options.*',
	                      :joins => ' LEFT JOIN product_option_values on product_options.id = product_option_values.product_option_id LEFT JOIN products_product_option_values ON product_option_values.id=products_product_option_values.product_option_value_id ',
	                      :conditions => "products_product_option_values.product_id=#{self.id} AND (SELECT count(*) from products_product_option_values LEFT JOIN product_option_values on products_product_option_values.product_option_value_id = product_option_values.id LEFT JOIN product_options as subquery_product_options on product_option_values.product_option_id = subquery_product_options.id WHERE products_product_option_values.product_id=#{self.id} and subquery_product_options.id=product_options.id) = 1",
	                      :order => 'product_options.id ASC' )
  end
	
	def product_option_values_for_product_option( product_option )
	  return [] if new_record?
  	ProductOptionValue.find(:all,
                            :select => "product_option_values.*",
                            :joins => "LEFT JOIN products_product_option_values on product_option_values.id = products_product_option_values.product_option_value_id",
                            :conditions => "products_product_option_values.product_id=#{self.id} and product_option_values.product_option_id=#{product_option.id}",
                            :order => "products_product_option_values.default DESC, product_option_values.id ASC" )  

  end
  
  def default_product_option_value( product_option )
    return [] if new_record?
    ProductOptionValue.find(  :first,
                              :joins => "LEFT JOIN products_product_option_values on product_option_values.id=products_product_option_values.product_option_value_id LEFT JOIN product_options on product_options.id = product_option_values.product_option_id",
                              :conditions => "products_product_option_values.product_id=#{self.id} AND product_options.id = #{product_option.id}",
                              :order => "products_product_option_values.default DESC" )

  end
  
  def default_option_values
    povs = product_options.inject({}) do |hash, option|
      hash[option.title] = default_product_option_value(option).label
      hash
    end
  end
	
	## Go through all the product_options submitted and make sure they are valid for this product
  ## This is especially important if the user made a change to the product_id, because the old product
  ## might have option values that are not applicable for this one.
  ## If we find any, try getting the default value. If there's no default value, then remove the option
  ## from the hash entirely.
	def valid_options( product_options )

    product_options.each do | option, value |
      this_option = ProductOption.find(:first, :conditions => "title = '#{option}'")
      this_pov = this_option.product_option_values.find(:first, :conditions => "label = '#{value}'")
      unless self.product_option_values.include?(this_pov)
        if default_option_value = self.default_product_option_value( this_option )
          product_options[option] = default_option_value.label
        else
          product_options.delete(option)
        end        
      end
    end
	  
	  return product_options
	end
	
	# Returns a symbol->[string] map of the product's possible
	# options.
	def options_map
		raw_options_map_to_soft_map( raw_options_map )
	end
	
	# This method takes a hash of keys to non-array values
	# and compares it to the valid options for this product,
	# returning true if it validates. 
	#
	# This method can take hard (activerecord) or soft
	# (symbol->[string]) hashes.
	def options_valid?( opts )
		ropts = raw_options_map
		sopts = raw_options_map_to_soft_map( raw_options_map )
		opts.keys.each do |opt|
			topts = opt.kind_of?( Symbol ) ? sopts : ropts
			if topts[opt]
				unless topts[opt].include?( opts[opt] )
					return false
				end
			end
			# return false
		end
		return true
	end
	
	# This method prices a product for a given
	# quantity and set of options, multiplying
	# the final price by markup.
	# --
	# TODO: throw exceptions instead of strings
	def price_for( quantity, opts={}, validate_options = true )
		if opts.keys.first and opts.keys.first.kind_of? String
		  rawopts = raw_options_map.merge( soft_options_set_to_raw_set(opts) )
		elsif opts.keys.first and opts.keys.first.kind_of? ProductOption 
		  rawopts = opts
		  soft = HashWithIndifferentAccess.new
		  opts.each_key { |key|
		    this_title = key.title.downcase
		    this_label = opts[key].label 
		    
		    soft[this_title] = this_label }
		  opts = soft
		end
		
		raise "Invalid options for Product" if validate_options and not options_valid?( opts )
		@price_explanations = []
		
		@price_explanations << opts.to_yaml
		option_multiplier = 1.0
		area = self.height * self.width
		@price_explanations << "Area is #{area}"
		
		ink = ProductOptionValue.find(:first, :conditions => ['label = ?', opts[:ink]])
		@price_explanations << "<b> INK POV IS NULL!!! #{opts[:ink]} </b>" if ink.nil?
		if ink and make_ready = self.make_readies.find(:first, :conditions => "product_option_value_id = #{ink.id}") and make_ready.price
		  cost = make_ready.price * area
		  @price_explanations << "MakeReady exists for this ink(#{opts[:ink]}): #{make_ready.price} * #{area} = #{cost}"
		elsif opts[:ink] == "4/0"
		  cost = ( self.setup_price / 2 ) * area
		  @price_explanations << "Product Setup Price (half for one-sidedness): #{self.setup_price} / 2 * #{area} = #{cost}"
		else
		  cost = self.setup_price.to_f * area
		  @price_explanations << "Product Setup Price: #{self.setup_price} * #{area} = #{cost}"
		end
		
		post_markup = 0.0
		
		rawopts.each_pair do |option, value|
		  next if option.title.downcase == "mailing"
		  option_cost = 0.0
		  
			value = (value.first or value.find { |x| x }) if value.kind_of? Array
			next if value.nil?
			@price_explanations << "<b>" + option.title  + ":" + value.label + "</b>"		  
			
			if option.setup_price and not ( value.label.downcase == "none" )
			  option_cost += option.setup_price 
			  @price_explanations << "Option Setup Price: #{option.setup_price}"
      end
      
			case value.kind
			when "Fixed"
			  if value.price_per_sqin and value.price_per_sqin > 0
			    option_cost +=  (value.price_per_sqin.to_f * area.to_f)
			    @price_explanations << "Option One-Time Area Charge: #{value.price_per_sqin} * #{area}sqin: #{option_cost}"
			  end
			  if value.price_per_unit and value.price_per_unit > 0
			    option_cost += value.price_per_unit 
			    @price_explanations << "Option One-Time Charge: #{value.price_per_unit}"
			  end
			when "Quantity"
			  option_cost += value.price_per_unit.to_f * (quantity.to_f / value.unit_quantity.to_f )
			  @price_explanations <<  "Option Per-Qty Charge: #{value.price_per_unit} * #{quantity} / #{value.unit_quantity}:" +
			                          (value.price_per_unit.to_f * (quantity.to_f / value.unit_quantity.to_f )).to_s
			when "Area"
			  option_cost += (value.price_per_sqin.to_f * area.to_f) * ( quantity.to_f / value.unit_quantity.to_f  )
			  @price_explanations << "Option Area*Qty Charge: #{value.price_per_sqin} * #{area} * #{quantity} / #{value.unit_quantity}: " +
			                          ((value.price_per_sqin.to_f * area.to_f) * ( quantity.to_f / value.unit_quantity.to_f  )).to_s
			when "Multiplier"
			  option_multiplier = option_multiplier.to_f * value.price_per_unit.to_f
			  @price_explanations << "Multiplier: #{value.price_per_unit}, Total Multiplier Now: " +  
			                          (option_multiplier.to_f * value.price_per_unit.to_f).to_s
			end
		  
		  @price_explanations << "This Option Cost: " + option_cost.to_s
		  if value.post_markup
		    post_markup += option_cost
		  else
		    cost += option_cost
		  end
		end
    
    @price_explanations << "Total Cost: " + cost.to_s
    unrounded_cost = (( cost * markup( quantity ) ) + cost )
    @price_explanations << "Cost After Markup: " + unrounded_cost.to_s
		multiplied_cost = unrounded_cost.to_f * option_multiplier.to_f
		@price_explanations << "Cost After Multiplier: " + multiplied_cost.to_s
		post_markup_cost = multiplied_cost + post_markup
		@price_explanations << "Cost After Post-Markup Options: " + post_markup_cost.to_s
		## trickyness to round up to the next $5 step	
		
		if post_markup_cost.divmod(5)[1] == 0
		  rounded_cost = post_markup_cost
		else
		  rounded_cost = (post_markup_cost.divmod( 5 )[0] + 1 ) * 5
		end
		@price_explanations << "Rounded Cost: " + rounded_cost.to_s
		return rounded_cost
	end

  def markup( quantity )
    return price_zone( quantity ).markup.to_f
  end
  
  def quantity_increment( quantity )
    return price_zone( quantity ).quantity_increment
  end
  
  def price_zone( quantity )
    if pz = PriceZone.find( :first, 
                            :conditions => "product_id=#{self.id} AND max_quantity >= #{quantity}",
                            :order => "max_quantity ASC" )  
    else
		  raise "There is no applicable price zone for the quantity specified."
		end                            
		return pz
  end
  
  def quantity_options    
    zones = self.price_zones
    q_options = []
    zones.each do | zone |
      i = zones.index( zone )
      start_q = if i == 0
                  0
                else
                  zones[ i - 1 ].max_quantity
                end
      this_q = start_q + zone.quantity_increment
      while this_q <= zone.max_quantity
        q_options << this_q
        this_q += zone.quantity_increment
      end
    end
    return q_options
  end
	
	def mailing_price( quantity = 0, option_label = 'First Class' )
    return 0 if quantity == 0 or option_label.nil? or option_label.downcase == "none" 
    cost = 0
    mailing_option = ProductOption.find(:first, :conditions => "title = 'Mailing'")
    this_option_value = ProductOptionValue.find(:first, :conditions => "label = '#{option_label}'")
    
    if this_price_zone = this_option_value.option_price_zones.find( :first, 
                                                                    :conditions => "max_quantity >= #{quantity}", 
                                                                    :order => 'max_quantity ASC' )
    else
      raise "No option price zone for this quantity (calculating mailing price)"
    end
        
    cost += this_price_zone.setup_price.to_f if this_price_zone.setup_price
   
    if this_price_zone.price_per_unit and this_price_zone.price_per_unit > 0
      cost += (quantity.to_f / this_price_zone.unit_quantity.to_f ) * this_price_zone.price_per_unit.to_f
    end
    
    return cost
  end

  def postage_price( quantity = 0, option_label = 'First Class' )
    return 0 if quantity == 0 or option_label.nil? or option_label.downcase == "none" 
    cost = 0
    mailing_option_value = ProductOptionValue.find(:first, :conditions => "label = '#{option_label}'")
    
    if this_postage = postages.find(:first, 
                                    :conditions => "min_quantity <= #{quantity} AND mailing_option_value_id = #{mailing_option_value.id}",
                                    :order => "min_quantity DESC" )
    else
      ### No options for that type of mail service; try first class.
      mailing_option_value = ProductOptionValue.find(:first, :conditions => "label = 'First Class'")
      if this_postage = postages.find(:first, 
                                      :conditions => "min_quantity <= #{quantity} AND mailing_option_value_id = #{mailing_option_value.id}",
                                      :order => "min_quantity DESC" )
      else
        raise "No postage setup for this quantity"
      end
    end
    
    cost = this_postage.price.to_f * quantity.to_f if this_postage.price
    return cost 
  end

	def weight_for( quantity, opts={} )
	  base_weight = self.weight_per_unit.to_f * ( quantity.to_f / self.weight_unit_size.to_f )
	  weight = base_weight
	  
	  rawopts = raw_options_map.merge( soft_options_set_to_raw_set(opts) )
	  rawopts.each do | option, value |
	    value = value[0] if value.kind_of? Array
	    if value.weight_multiplier and value.weight_multiplier > 0
	      weight += base_weight * value.weight_multiplier
	    end
	  end
	  
	  return weight
	end
	
	def boxes_for( quantity, opts={} )
	  if opts.keys.first.kind_of?(ProductOption)
	    rawopts = opts
	  else
	    rawopts = raw_options_map.merge( soft_options_set_to_raw_set(opts) )
	  end
	  
	  this_coating = (rawopts.find { | option, value | option.title.downcase == "coating" }.last if opts.key? 'coating') or nil
	  this_folding = (rawopts.find { | option, value | option.title.downcase == "folding" }.last if opts.key? 'folding') or nil

    conditions = []
    conditions << "coating_id = #{this_coating.id} OR coating_id IS NULL" if this_coating
    conditions << "folding_id = #{this_folding.id} OR folding_id IS NULL" if this_folding
    conditions = conditions.collect { |c| "(" + c + ")" } if conditions.length > 1
    available_boxes = self.boxed_products.find( :all, 
                                                :conditions => (conditions.join(" AND ") unless conditions.empty?), 
                                                :order => "max_quantity ASC" )
    boxes_used = []
    packed_q = 0
    required_space = quantity
    
    until packed_q >= quantity.to_f do 
      begin
        this_box = ( available_boxes.find{ |b| b.max_quantity >= required_space } || available_boxes.last ).clone
      rescue
        raise "no boxes for product: " + self.title.to_s + "(#{self.id})"
      end
      this_box.soft_options = opts
      this_box.quantity_inside = required_space if required_space <= this_box.max_quantity
      boxes_used << this_box
      packed_q += this_box.max_quantity
      required_space -= this_box.max_quantity
    end
	  
	  return boxes_used
	end
	
	
	# This method explains how the price for a product 
	# is dirived. Not for actual public consumption
	def price_explain( quantity, markup=1.0, opts={} )
		raise "Invalid options for Product" unless options_valid?( opts )
	  output = ""
    
    # Calculate Area
		area = self.height * self.width
		output += "<p>Area: #{self.height} (Height) x #{self.width} (Width) = #{area}</p>"
    
    # Calculate Setup Price
		cost = self.setup_price * area
		output += "<p>Setup price: #{self.setup_price} (Base) x #{area} (Area) = #{cost}</p>"
		
		# Price each option
		rawopts = raw_options_map.merge( soft_options_set_to_raw_set(opts) )
		rawopts.each_pair do |option, value|
			value = value.first if value.kind_of? Array
			opt_output = "<b>Option: #{option.title}[#{value.label}]</b><br>"
			
			#Calculate Option Setup
			opt_setup_cost = 0
			if !option.setup_price.nil? && option.setup_price > 0
			  opt_setup_cost = option.setup_price
				opt_output += "Option Setup: #{option.setup_price}<br />"
			end
		
					
			if value.price_per_unit
        # Calculate ajusted cost
				adjusted_cost = ((value.price_per_unit.to_f) / value.unit_quantity.to_f)
				opt_output += "Cost Adjusted for Quantity Break: #{value.price_per_unit} (Price) / #{value.unit_quantity} (Qty) = #{adjusted_cost}<br />"		  

        # Calculate cost
				option_cost = opt_setup_cost + (adjusted_cost * quantity)
				opt_output += "Option Cost: #{adjusted_cost} (Price) x #{quantity} (Qty) = #{option_cost}<br />"

        # Calculate running total
				cost += option_cost
				opt_output += "Running Subtotal: #{cost}"
			else
        # Calculate ajusted cost
				adjusted_cost = (value.price_per_sqin / value.unit_quantity)
				opt_output += "Cost Adjusted for Quantity Break: #{value.price_per_sqin} (Price) / #{value.unit_quantity} (Qty) = #{adjusted_cost}<br />"	  

        # Calculate cost
				option_cost = adjusted_cost * area * quantity
				opt_output += "Option Cost: #{adjusted_cost} (Cost) x #{area} (Area) x #{quantity} (Qty) = #{option_cost}<br />"

        # Calculate running total
			  cost += option_cost
				opt_output += "Running Subtotal: #{cost}"
			end
			output += "<p>#{opt_output}</p>"
		end
		
		# Calculate price
		price = cost * markup
		output += "<p><b>Total:</b> #{cost} (Base) x #{markup} (Markup) = #{price}</p>"
		
		return output
	end
	
	def soft_options_set_to_raw_set( sopts )
	  return {} if sopts.keys.empty?
	  @raw_sets ||= {}	  
	  @raw_sets[sopts.to_s] ||= ProductOption.find( :all, :include => :product_option_values, :order => 'title', 
                          :conditions => sopts.keys.collect { |title| [title, sopts[title]] }.flatten.insert(0,(["(product_options.title=? AND product_option_values.label=?)"] * sopts.keys.length).join(' OR '))).                          
                          inject({}) do |hash, option|
                                        hash[option] = option.product_option_values.first
                                        hash
                                      end
	end
	
	def next_quantity_step(actual)
	  return 0 if actual == 0
    quantity_options.sort{ |a,b| a <=> b }.find { |q| q >= actual } or actual
  end

	private
	
	# Returns an options map as above in options_map, 
	# but instead of containing symbols and strings, it 
	# contains activerecord objects
	def raw_options_map_old
		res = {}
		options = self.product_options
		
		options.each do |opt|
			key = opt
			res[key] = self.product_option_values.find( :all, :conditions => "product_option_id = #{opt.id}", :order => '`default` DESC' )
		end		
		return res
	end
	
	def raw_options_map
    return {} if product_options.empty?
    @@raw_options_hashes ||= {}
    @@raw_options_hashes[self.id] ||= {}
    @@raw_options_hashes[self.id][product_options] ||= product_options.inject({}) do |hash, option|
      hash[option] = self.product_option_values.find( :all, :conditions => "product_option_id = #{option.id}", 
                                                      :order => '`default` DESC')
      hash
    end
  end
	
	# This converts a raw options map to a soft options map.
	def raw_options_map_to_soft_map( ropts )
		res = {}
		rmap = ropts
		rmap.keys.each do |opt|
			res[opt.title.downcase.to_sym] =
				rmap[opt].collect { |val| val.label }
		end
		return res
	end
	
	
	# This converts a soft options set (meaning, the values
	# stored are singular, not arrays) to a raw option set, using
	# find_by_title for options and find_by_label for option values.


end
