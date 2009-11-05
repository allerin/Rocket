class UPS

class Base
  attr_reader :access_request, :access_request_buffer
  
  def initialize( options = {} )
    @config = YAML::load(File.open("#{RAILS_ROOT}/lib/ups/ups_config.yml"))
    @response = nil
    
    @access_request_buffer = ""
    @access_request = Builder::XmlMarkup.new :target => @access_request_buffer, :indent => 2
    @access_request.instruct! :xml, :version => "1.0"
    
    @access_request.AccessRequest { @access_request.AccessLicenseNumber @config['license']
                                    @access_request.UserId @config['user_id']
                                    @access_request.Password @config['password'] }
  end
  
end  
  
  
end