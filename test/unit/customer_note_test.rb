require File.dirname(__FILE__) + '/../test_helper'

class CustomerNoteTest < Test::Unit::TestCase
  fixtures :customer_notes

  # Replace this with your real tests.
  def test_truth
    assert_kind_of CustomerNote, customer_notes(:first)
  end
end
