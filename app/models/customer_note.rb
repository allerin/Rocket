class CustomerNote < Note
  belongs_to :user
  belongs_to :customer, :foreign_key => 'record_id'
end
