require File.dirname(__FILE__) + '/../test_helper'

class InvoiceNoteTest < Test::Unit::TestCase
  fixtures :invoice_notes

  # Replace this with your real tests.
  def test_truth
    assert_kind_of InvoiceNote, invoice_notes(:first)
  end
end
