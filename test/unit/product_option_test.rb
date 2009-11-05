require File.dirname(__FILE__) + '/../test_helper'

class OptionTest < Test::Unit::TestCase
  fixtures :options

  def setup
    @option = Option.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Option,  @option
  end
end
