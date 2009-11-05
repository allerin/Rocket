module CartShippable
  attr_accessor :shipping_method_id
  attr_reader :shipping_address_id
  attr_writer :shipping_methods
  
  def shipping_address
    if @shipping_address and @shipping_address_id and @shipping_address.id == @shipping_address_id
      return @shipping_address
    elsif @shipping_address_id
      return @shipping_address = Address.find( :first, :conditions => ["id = ?", @shipping_address_id])
    end
    return nil
  end
  
  def shipping_address=(sa)
    @shipping_address = sa
    @shipping_address_id = sa.id
  end
  
  def shipping_address_id=(said)
    if said.nil?
      @shipping_address_id = @shipping_address = nil
    else
      @shipping_address_id = said
    end
  end
  
  def shipping_methods
    @shipping_methods ||= []
  end
  
  def boxes    
    return product.boxes_for( shipping_quantity, soft_options )    
  end
  
  def get_ups_rates
    self.shipping_methods = ShippingMethod.find(:all, :conditions => "ups_service_code IS NOT NULL")
    
    if boxes.length > 0 
      ups = UPS::RatesAndServicesRequest.new
      if shipping_address
        ups.build_rate_request( boxes, shipping_address)
        ups.submit_request
        ups_rated_shipments = ups.rated_shipments.clone  
      
        self.shipping_methods.each do | method |
          if rate = ups_rated_shipments.find{ |s| s.code.to_s == method.ups_service_code.to_s }
            method.cost = rate.total_charges
          end
        end
      end
    end
  end
  
  def shipping_price
    return ( shipping_method.cost or 0.0 ) rescue 0.0
  end
    
  ## Note that if you want to ensure your methods are fresh, you should call shipping_methods first.
  def shipping_method
    shipping_methods.find{ |m| m.id == shipping_method_id.to_i } if shipping_method_id
  end
  
end