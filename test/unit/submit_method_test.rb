require File.dirname(__FILE__) + '/../test_helper'

class SubmitMethodTest < Test::Unit::TestCase
  fixtures :submit_methods

  def setup
    @submit_method = SubmitMethod.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of SubmitMethod,  @submit_method
  end
end
