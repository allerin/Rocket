require File.dirname(__FILE__) + '/../test_helper'

class PaymentTest < Test::Unit::TestCase
  fixtures :payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Payment, payments(:first)
  end
end
