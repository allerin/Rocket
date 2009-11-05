class OrderNote < Note
  belongs_to :user
  belongs_to :order, :foreign_key => 'record_id'
end
