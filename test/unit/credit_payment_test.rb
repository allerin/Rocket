require File.dirname(__FILE__) + '/../test_helper'

class CreditPaymentTest < Test::Unit::TestCase
  fixtures :credit_payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of CreditPayment, credit_payments(:first)
  end
end
