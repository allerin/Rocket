require File.dirname(__FILE__) + '/../test_helper'

class OrderStatusTest < Test::Unit::TestCase
  fixtures :order_statuses

  # Replace this with your real tests.
  def test_truth
    assert_kind_of OrderStatus, order_statuses(:first)
  end
end
