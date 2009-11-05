require File.dirname(__FILE__) + '/../test_helper'

class AddressTest < Test::Unit::TestCase
  fixtures :addresses

  def setup
    @address = Address.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Address,  @address
  end
end
