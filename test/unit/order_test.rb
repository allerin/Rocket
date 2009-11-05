require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < Test::Unit::TestCase
  fixtures :orders

  def setup
    @order = Order.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Order,  @order
  end
end
