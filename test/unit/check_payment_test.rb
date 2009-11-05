require File.dirname(__FILE__) + '/../test_helper'

class CheckPaymentTest < Test::Unit::TestCase
  fixtures :check_payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of CheckPayment, check_payments(:first)
  end
end
