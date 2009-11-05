require File.dirname(__FILE__) + '/../test_helper'

class ShippingMethodTest < Test::Unit::TestCase
  fixtures :shipping_methods

  def setup
    @shipping_method = ShippingMethod.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of ShippingMethod,  @shipping_method
  end
end
