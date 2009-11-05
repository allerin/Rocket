require File.dirname(__FILE__) + '/../test_helper'

class TradePaymentTest < Test::Unit::TestCase
  fixtures :trade_payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of TradePayment, trade_payments(:first)
  end
end
