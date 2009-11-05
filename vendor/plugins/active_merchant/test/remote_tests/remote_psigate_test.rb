require 'test/unit'
require File.dirname(__FILE__) + '/../test_helper'

class PsigateRemoteTest < Test::Unit::TestCase
  include ActiveMerchant::Billing
  
  # set up order numbers as contants because even a test credit must match an 
  # existing purchase in psigate's test system
  ORDER_NUM1 = Time.now.to_i.to_s
  ORDER_NUM2 = (Time.now.to_i + 1).to_s
  ORDER_NUM3 = (Time.now.to_i + 2).to_s
  
  def setup
    ActiveMerchant::Billing::Base.gateway_mode = :production
    @gateway = PsigateGateway.new({
      :store_id => 'teststore',
      :password => 'psigate1234',
    })

    @creditcard = CreditCard.new({
      :number => '4242424242424242',
      :month => 8,
      :year => 2006,
      :first_name => 'Longbob',
      :last_name => 'Longsen'
    })
  end
  
  def test_remote_authorize
    assert response = @gateway.authorize(Money.us_dollar(2400), @creditcard, {:order_id => ORDER_NUM1,
       :billing_address => {
          :address1 => '123 fairweather Lane',
          :address2 => 'Apt B',
          :city => 'New York',
          :state => 'NY',
          :country => 'U.S.A.',
          :zip => '10010'},
      :email => 'jack@yahoo.com'
      })
    assert_equal Response, response.class
    assert_equal true, response.success?
    assert_equal "APPROVED", response.params["approved"]
    assert_equal ORDER_NUM1, response.authorization
  end
  
  def test_remote_capture
    assert response = @gateway.capture(Money.us_dollar(2400), ORDER_NUM1 )
    assert_equal Response, response.class
    assert_equal true, response.success?
    assert_equal "APPROVED", response.params["approved"]
    assert_equal "APPROVED", response.params["approved"]
  end
  
  
  # named test_remote_apurchase (with an a) so that it executes prior to the 
  # test_remote_credit method. Otherwise the credit won't reference an existing
  # purchase and the test will fail
  def test_remote_apurchase
    assert response = @gateway.purchase(Money.us_dollar(2400), @creditcard, {:order_id =>  ORDER_NUM2,
       :billing_address => {
          :address1 => '123 fairweather Lane',
          :address2 => 'Apt B',
          :city => 'New York',
          :state => 'NY',
          :country => 'U.S.A.',
          :zip => '10010'},
      :email => 'jack@yahoo.com'
      })
    assert_equal Response, response.class
    assert_equal true, response.success?
    assert_equal "APPROVED", response.params["approved"]
  end
  
  def test_remote_credit
    assert response = @gateway.credit(Money.us_dollar(2400), CreditCard.new({}), {:order_id =>  ORDER_NUM2 })
    assert_equal Response, response.class
    assert_equal true, response.success?
    assert_equal "APPROVED", response.params["approved"]
  end
  
  def test_remote_decline
    assert response = @gateway.purchase(Money.us_dollar(2400), @creditcard, {:order_id =>  ORDER_NUM3,
       :billing_address => {
          :address1 => '123 fairweather Lane',
          :address2 => 'Apt B',
          :city => 'New York',
          :state => 'NY',
          :country => 'U.S.A.',
          :zip => '10010'},
      :email => 'jack@yahoo.com',
      :test_result => 'D'
      })
    assert_equal Response, response.class
    assert_equal false, response.success?
    assert_equal "DECLINED", response.params["approved"]
  end
  
end