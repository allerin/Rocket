require File.dirname(__FILE__) + '/../test_helper'

class ProductOptionValuesTest < Test::Unit::TestCase
  fixtures :product_option_values

  def setup
    @product_option_values = ProductOptionValues.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of ProductOptionValues,  @product_option_values
  end
end
