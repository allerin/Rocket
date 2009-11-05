require File.dirname(__FILE__) + '/../test_helper'

class OrderNoteTest < Test::Unit::TestCase
  fixtures :order_notes

  def setup
    @order_note = OrderNote.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of OrderNote,  @order_note
  end
end
