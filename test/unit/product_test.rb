require File.dirname(__FILE__) + '/../test_helper'

class ProductTest < Test::Unit::TestCase
  fixtures :products

  def setup
    @product = Product.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Product,  @product
  end
end
