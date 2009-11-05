require File.dirname(__FILE__) + '/../../test_helper'

class RemoteTest < Test::Unit::TestCase
  include ActiveMerchant::Billing

  def test_raw
    PaypalNotification.ipn_url = "https://www.sandbox.paypal.com/cgi-bin/webscr"
    @paypal = PaypalNotification.new('')
    
    assert_nothing_raised do
      assert_equal false, @paypal.acknowledge    
    end
  end
end
