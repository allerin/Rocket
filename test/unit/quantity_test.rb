require File.dirname(__FILE__) + '/../test_helper'

class QuantityTest < Test::Unit::TestCase
  fixtures :quantities

  def setup
    @quantity = Quantity.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Quantity,  @quantity
  end
end
