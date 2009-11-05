require 'ups/base'

class UPS

class RatesAndServicesRequest < UPS::Base
  
  include REXML
  
  attr_reader :rate_request_buffer, :rate_request, :response
  attr_accessor :instructed
  
  def initialize( options = {} )
    super options
    
    @rate_request_buffer = ""
    @rate_request = Builder::XmlMarkup.new :target => @rate_request_buffer, :indent => 2
    @rate_request.instruct! :xml, :version => "1.0" 
    @instructed = false
  end
  
  def request
    @access_request_buffer + @rate_request_buffer
  end
  
  ## your packages have to respond to a few methods: depth(), width(), height(), and packed_weight()
  ## and your address has to respond to zip()
  def build_rate_request( packages, address, options = {} )
    options = @config['rates_and_services'].merge options
    
    @rate_request.RatingServiceSelectionRequest { 
      @rate_request.Request {
        @rate_request.TransactionReference {
          @rate_request.CustomerContext "Rating and Service"
          @rate_request.XpciVersion "1.0001" 
        }
        @rate_request.RequestAction "Rate"
        @rate_request.RequestOption "shop" 
      }
      @rate_request.PickupType { @rate_request.Code options['pickup_type'] }
      @rate_request.Shipment {
        @rate_request.Shipper { 
          @rate_request.Address { @rate_request.PostalCode options['shipper_postal_code'] } }
        @rate_request.ShipTo {
          @rate_request.Address {
            @rate_request.PostalCode address.zip
            @rate_request.CountryCode "US"
          }
        }
        @rate_request.Service { @rate_request.Code "01" }
        
        packages.each do | package |        
          @rate_request.Package {
            @rate_request.PackagingType { @rate_request.Code "02" }
            @rate_request.Dimensions {
              @rate_request.Length package.depth.to_s
              @rate_request.Width package.width.to_s
              @rate_request.Height package.height.to_s
            }
            @rate_request.PackageWeight {
              @rate_request.Weight package.packed_weight.to_s
            }
          }
        end
        
      }
    }
  end
  
  def submit_request( options = {})
    options = @config['rates_and_services'].merge options
    @h = Net::HTTP.new(options['host'], options['port'])
    @h.use_ssl = true
    @response = @h.post( options['document'], request )
  end

  def rated_shipments
    raise "No XML response received!" unless @response and @response.length > 0
    
    services = []
    
    doc = Document.new @response.body
    doc.root.each_element( 'RatedShipment' ) do | rate |
      service = UPS::RatedShipment.new
      service.code = rate.get_text('Service/Code').to_s
      service.billing_weight = rate.get_text('BillingWeight/Weight').to_s.to_f
      service.transportation_charge = rate.get_text('TransportationCharges/MonetaryValue').to_s.to_f
      service.service_options_charge = rate.get_text('ServiceOptionsCharges/MonetaryValue').to_s.to_f
      service.total_charges = rate.get_text('TotalCharges/MonetaryValue').to_s.to_f
      service.guaranteed_days_to_delivery = rate.get_text('GuaranteedDaysToDelivery').to_s.to_i
      service.scheduled_delivery_time = rate.get_text('ScheduledDeliveryTime').to_s
      services << service
    end
    
    return services
  end
  
end

class RatedShipment
  attr_accessor :code, :transportation_charge, :service_options_charge, 
                :total_charges, :guaranteed_days_to_delivery, :scheduled_delivery_time,
                :billing_weight
                
  SERVICES = {  '01' => "UPS Next Day Air",
                '02' => "UPS 2nd Day Air",
                '03' => "UPS Ground",
                '07' => "UPS Worldwide Express",
                '08' => "UPS Worldwide Expedited",
                '11' => "UPS Standard",
                '12' => "UPS 3-Day Select",
                '13' => "UPS Next Day Air Saver",
                '14' => "UPS Next Day Air Early AM",
                '54' => "UPS Worldwide Express Plus",
                '59' => "UPS 2nd Day Air AM",
                '65' => "UPS Express Saver" }
  
  def initialize( code = '', transportation_charge = 0.0, service_options_charge = 0.0, 
                  total_charges = 0.0, guaranteed_days_to_delivery = nil, billing_weight = 0.0 )
    @code = code
    @transportation_charge = transportation_charge
    @service_options_charge = service_options_charge
    @total_charges = total_charges
    @guaranteed_days_to_delivery = guaranteed_days_to_delivery
    @billing_weight = billing_weight
  end
  
  def service_name
    return SERVICES[ code.to_s ]
  end
  
end


end