require 'payment/base'
require 'cgi'
require 'csv'
require 'rjb'

module Payment

class VerisignPayflowPro < Payment::Base
	attr_reader :response, :avs_match_addr, :avs_match_zip, :avs_international, :cvv2_response, :host_code
	attr_accessor :cert_path, :port, :timeout, :partner, :cvv2, :trans_id
	attr_accessor :proxy_address, :proxy_port, :proxy_logon, :proxy_password
	
	# map the instance variable names to the gateway's requested variable names
	FIELDS = {
		'TRXTYPE' => 'action',
		'PARTNER' => 'partner',
		'USER' => 'login',
		'VENDOR' => 'login',
		'TENDER' => 'type', 
		'PWD' => 'password',
		'ACCT' => 'card_number',
		'EXPDATE' => 'expiration',
		'AMT' => 'amount',
		'COMMENT1' => 'comment_1',
		'COMMENT2' => 'comment_2',
		'DESC' => 'description',
		'INVNUM' => 'invoice_num',
		'ORIGID' => 'trans_id',
		'AUTHCODE' => 'auth_code',
		'CUSTREF' => 'cust_id',
		'LASTNAME' => 'last_name',
		'FIRSTNAME' => 'first_name',
		'NAME' => 'name', 
		'COMPANYNAME' => 'company',
		'STREET' => 'address',
		'CITY' => 'city',
		'STATE' => 'state',
		'ZIP' => 'zip',
		'COUNTRY' => 'country',
		'SHIPTOLASTNAME' => 'ship_to_last_name',
		'SHIPTOFIRSTNAME' => 'ship_to_first_name',
		'SHIPTOSTREET' => 'ship_to_address',
		'SHIPTOCITY' => 'ship_to_city',
		'SHIPTOSTATE' => 'ship_to_state',
		'SHIPTOZIP' => 'ship_to_zip',
		'SHIPTOCOUNTRY' => 'ship_to_country',
		'PHONENUM' => 'phone',
		'EMAIL' => 'email',
		'CVV2' => 'card_code',
		'NAME' => 'account_name',
		'MICR' => 'micr',
		'CHKTYPE' => 'account_type',
		'SS' => 'customer_ssn',
		'DL' => 'drivers_license_num',
		'DOB' => 'drivers_license_dob',
		'RECURRING' => 'recurring_billing',
	}
	
	# map the actions to the merchant's action names
	ACTIONS = {
		'sale'                 => 'S',
		'authorization'        => 'A',
		'voice authorization'  => 'F',
		'credit'               => 'C',
		'post authorization'   => 'D',
		'void'                 => 'V',
		'inquiry'              => 'I',
	}
	
	# map the organizations to the organizations names
	ACCOUNTTYPES = {
		'personal' => 'P',
		'company'  => 'C',
	}
	
	# map the tender types to the tender names
	TENDERS = {
		'cc'     => 'C',
		'check'  => 'K',
	}
	
	#map the response fields to state
	RESPONSEFIELDS = {
		'PNREF' => 'trans_id',
		'RESULT' => 'result_code',
		'CVV2MATCH' => 'cvv2_response',
		'RESPMSG' => 'error_message',
		'AUTHCODE' => 'authorization',
		'AVSADDR' => 'avs_match_addr',
		'AVSZIP' => 'avs_match_zip',
		'IAVS' => 'avs_international',
		'HOSTCODE' => 'host_code',
		}

	def initialize(options = {})

		# set some sensible defaults
		@url = 'payflow.verisign.com'
		@port = '443'
		@timeout = '30'
		@cert_path = '/etc/certs/'
		@partner = 'verisign'
		@proxy_address = ''
		@proxy_port = '0'
		@proxy_logon = ''
		@proxy_password = ''
		@action = 'sale'
		@type = 'cc'
		
		# include all provided data
		super options
		
		#set up the payment processor
		Rjb::load
		
 		@@klass = Rjb::import('com.Verisign.payment.PFProAPI')
		@processor = @@klass.new()
		@processor.SetCertPath(cert_path)
		@processor.CreateContext(url, port.to_i, timeout.to_i, proxy_address, proxy_port.to_i, proxy_logon, proxy_password)

	end

	def process()
		
 		@response = @processor.SubmitTransaction(post_data)
 		
 		@response.split("&").each do |row|
 			row_array = row.split('=')
 			if RESPONSEFIELDS.include?(row_array[0])
 				eval "@#{RESPONSEFIELDS[row_array[0]]} = '#{row_array[1]}'"
 			end
 		end
	
	end
	
	def post_data
		prepare_data

		post_array = Array.new
		FIELDS.each do |gate_var, loc_var|
			if @@required.include?(loc_var) && eval("@#{loc_var}").nil?
				raise PaymentError, "The required variable '#{loc_var}' was left empty"
			elsif eval("@#{loc_var}")
				value = eval "CGI.escape(@#{loc_var}.to_s)"
				post_array << "#{gate_var}=#{value}"
			end
		end

		return post_array.join("&")
	end
	
	def prepare_data
		# make sensible changes to data
		@card_number = @card_number.to_s.gsub(/[^\d]/, "") unless @card_number.nil?
		
		if @recurring_billing.class != String
			if @recurring_billing == true
				@recurring_billing = "YES"
			elsif @recurring_billing == false
				@recurring_billing = "NO"
			end
		end
		
		@expiration = @expiration.strftime "%m%y" rescue nil # in case a date or time is passed
		
		if TENDERS.include?(@type)
			@type = TENDERS[@type]
		elsif ! TENDERS.has_value?(@type)
			raise PaymentError, "The tender type '#{@type}' is not valid"
		end		
		
		# convert the action
		if ACTIONS.include?(@action)
			@action = ACTIONS[@action]
		elsif ! ACTIONS.has_value?(@action)
			raise PaymentError, "The action '#{@action}' is not valid"
		end		
		
		if @type == 'K' && @action != 'V'
			if ACCOUNTTYPES.include?(@account_type)
				@account_type = ACCOUNTTYPES[@account_type]
			elsif ! ACTIONS.has_value?(@account_type)
				raise PaymentError, "The checking account type '#{@account_type}' is not valid"
			end		
		end
		
		# add some required fields specific to this payment gateway and the provided data
		@@required.concat %w(type action login password)
		
		unless @type == 'V'
			@@required.concat %w(amount)
			if @tender == 'K'
				@@required.concat %w(city check_number email micr account_name state street zip)
				
				if @account_type == 'P'
					@@required.concat @customer_ssn ? %w(customer_ssn)  : %w(drivers_license_num)
					@@required.concat %w(drivers_license_dob) unless @drivers_license_dob.nil
				else
					@@required.concat %w(customer_ssn)
				end
			elsif @tender == 'C'
				if @action == 'D'
					@@required.concat %w(trans_id)
				elsif @action == 'F'
					@@required.concat %w(trans_id card_number expiration) 
				elsif @action == 'I'
					@@required.concat @cust_id ? %w(cust_id) : %w(trans_id)
				else
					@@required.concat %w(card_number expiration)
				end
			end
		end
		
		@@required.uniq!
	end

end

end
