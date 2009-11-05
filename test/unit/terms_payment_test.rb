require File.dirname(__FILE__) + '/../test_helper'

class TermsPaymentTest < Test::Unit::TestCase
  fixtures :terms_payments

  # Replace this with your real tests.
  def test_truth
    assert_kind_of TermsPayment, terms_payments(:first)
  end
end
