require File.dirname(__FILE__) + '/../test_helper'

class ProofMethodTest < Test::Unit::TestCase
  fixtures :proof_methods

  def setup
    @proof_method = ProofMethod.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of ProofMethod,  @proof_method
  end
end
