require File.dirname(__FILE__) + '/../test_helper'

class RocketImportTest < Test::Unit::TestCase
  fixtures :rocket_import

  # Replace this with your real tests.
  def test_truth
    assert_kind_of RocketImport, rocket_import(:first)
  end
end
