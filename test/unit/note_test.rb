require File.dirname(__FILE__) + '/../test_helper'

class NoteTest < Test::Unit::TestCase
  fixtures :notes

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Note, notes(:first)
  end
end
