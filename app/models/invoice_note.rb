class InvoiceNote < Note
  belongs_to :user
  belongs_to :invoice, :foreign_key => 'record_id'
end
