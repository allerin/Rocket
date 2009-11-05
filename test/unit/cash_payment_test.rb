require File.dirname(__FILE__) + '/../test_helper'

class CashPaymentTest < Test::Unit::TestCase
  fixtures :cash_payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of CashPayment, cash_payments(:first)
  end
end
