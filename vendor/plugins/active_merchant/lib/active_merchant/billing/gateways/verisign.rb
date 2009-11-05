module ActiveMerchant
  module Billing
        
    class VerisignGateway < Gateway
      CERTS_PARENT_PATH = '/Library/Rails/fantasql/current/'
      
      API_VERSION = '3.1'
      GATEWAY_SERVER = "test-payflow.verisign.com"
      #GATEWAY_SERVER = "payflow.verisign.com"
      GATEWAY_PORT = 443
      
      APPROVED = 0

      RESPONSE_CODE, RESPONSE_REASON_CODE, RESPONSE_REASON_TEXT = 0, 2, 3
      AVS_RESULT_CODE, TRANSACTION_ID, CARD_CODE_RESPONSE_CODE  = 5, 6, 38

      CARD_CODE_ERRORS = %w( N S )

      CARD_CODE_MESSAGES = {
        "M" => "Card verification number matched",
        "N" => "Card verification number didn't match",
        "P" => "Card verification number was not processed",
        "S" => "Card verification number should be on card but was not indicated",
        "U" => "Issuer was not certified for card verification"
      }

      AVS_ERRORS = %w( A E N R W Z )

      AVS_MESSAGES = {
        "A" => "Street address matches billing information, zip/postal code does not",
        "B" => "Address information not provided for address verification check",
        "E" => "Address verification service error",
        "G" => "Non-U.S. card-issuing bank",
        "N" => "Neither street address nor zip/postal match billing information",
        "P" => "Address verification not applicable for this transaction",
        "R" => "Payment gateway was unavailable or timed out",
        "S" => "Address verification service not supported by issuer",
        "U" => "Address information is unavailable",
        "W" => "9-digit zip/postal code matches billing information, street address does not",
        "X" => "Street address and 9-digit zip/postal code matches billing information",
        "Y" => "Street address and 5-digit zip/postal code matches billing information",
        "Z" => "5-digit zip/postal code matches billing information, street address does not",
      }
     
      # URL
      attr_reader :url 
      attr_reader :response
      attr_reader :options

      def initialize(options = {})
      #  requires!(options, :login, :password)
        
        # these are the defaults for the authorized test server
        @options = {
          :login      => "Y",
          :password   => "X",          
        }.update(options)
                                           
        super
      end  
      
      def authorize(money, creditcard, options = {})
        post = {}
        add_creditcard(post, creditcard)        
        add_address(post, options)        
        
        commit('A', money, post)
      end
      
      def purchase(money, creditcard, options = {})
        post = {}
        add_creditcard(post, creditcard)        
        add_address(post, options)   
             
        commit('S', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        post = {'ORIGID' => authorization, 'TENDER' => 'C'}
        commit('D', money, post)
      end
      
      def credit(money, authorization, options = {})
        post = {'ORIGID' => authorization, 'TENDER' => 'C'}
        commit('C', money, post)
      end
      
      # We support visa and master card
      def self.supported_cardtypes
        [:visa, :master, :american_express]
      end
         
      private                       
    
      def amount(money)          
        cents = money.respond_to?(:cents) ? money.cents : money 
        
        if money.is_a?(String) or cents.to_i <= 0
          raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.' 
        end

        sprintf("%.2f", cents.to_f/100)
      end             
    
      def expdate(creditcard)
        year  = sprintf("%.4i", creditcard.year)
        month = sprintf("%.2i", creditcard.month)

        "#{year[-2..-1]}#{month}"
      end
  
      def commit(action, money, parameters)
        parameters['AMT'] = amount(money)
        parameters['TRXTYPE'] = action
        
        if result = test_result_from_cc_number(parameters[:card_num])
          return result
        end
      
        Dir.chdir(CERTS_PARENT_PATH) if Dir['certs'].empty?
            
        data = `java -classpath #{RAILS_ROOT}/vendor/plugins/active_merchant/lib/active_merchant/billing/gateways/verisign/:#{RAILS_ROOT}/vendor/plugins/active_merchant/lib/active_merchant/billing/gateways/verisign/Verisign.jar PFProJava #{GATEWAY_SERVER} #{GATEWAY_PORT} "#{post_data(parameters)}"`
      
        c = ActionController::Base.new
        c.logger.info("\n\n\n\n\n" + "java -classpath #{RAILS_ROOT}/vendor/plugins/active_merchant/lib/active_merchant/billing/gateways/verisign/:#{RAILS_ROOT}/vendor/plugins/active_merchant/lib/active_merchant/billing/gateways/verisign/Verisign.jar PFProJava #{GATEWAY_SERVER} #{GATEWAY_PORT} \"#{post_data(parameters)}\"")
        
        c.logger.info("\n\n" + data + "\n\n\n\n\n\n")
        
        @response = parse(data)
        success = @response[:response_code] == APPROVED
        message = message_from(@response)

        Response.new(success, message, @response, 
            :test => false, 
            :authorization => @response[:transaction_id]
        )        
      end
                                               
      def parse(body)
        #fields = body[1..-2].split(/\$,\$/)
        fields = {}
        body.split('&').each { |string|
          key = string.split('=').first
          fields[key] = string.split('=').last
        }
               
               
        results = {         
          :response_code => (fields['RESULT'] ? fields['RESULT'].to_i : nil),
          :response_reason_code => fields['RESULT'], 
          :response_reason_text => fields['RESPMSG'],
          :avs_result_code => fields['AVSZIP'],
          :transaction_id => fields['PNREF'],
          :card_code => fields['CVV2MATCH']          
        }      
        
        results
      end     

      def post_data(parameters = {})
        post = {}
        post['USER'] = 'nomaddesign'
        post['VENDOR'] = 'nomaddesign'
        post['PARTNER'] = 'VeriSign'
        post['PWD'] = 'webadmin77'
        
        request = post.merge(parameters).collect { |key, value| "#{key}=#{CGI.escape(value.to_s).gsub('+', ' ')}" }.join("&")
        request
        
      end
      
      def add_creditcard(post, creditcard)      
        post['ACCT']  = creditcard.number
        post['TENDER'] = 'C'
        post['CVV2'] = creditcard.verification_value if creditcard.verification_value?
        post['EXPDATE']  = expdate(creditcard)
        post['NAME']  = [ creditcard.first_name, creditcard.last_name ].join(' ')
      end

      def add_address(post, options)      
        post['ADDRESS'] = options[:address] if options[:address]
        post['ZIP'] = options[:zip] if options[:zip]
      end
    
      # Make a ruby type out of the response string
      def normalize(field)
        case field
        when "true"   then true
        when "false"  then false
        when ""       then nil
        when "null"   then nil
        else field
        end        
      end          
      
      def message_from(results)        
#        if results[:response_code] != APPROVED
#          return CARD_CODE_MESSAGES[results[:card_code]] if CARD_CODE_ERRORS.include?(results[:card_code])
#          return AVS_MESSAGES[results[:avs_result_code]] if AVS_ERRORS.include?(results[:avs_result_code])
#        end
        
        return results[:response_reason_text] # Forget the punctuation at the end
      end
        
      def expdate(creditcard)
        year  = sprintf("%.4i", creditcard.year.to_i)
        month = sprintf("%.2i", creditcard.month.to_i)

        "#{month}#{year[-2..-1]}"
      end
    end
  end
end