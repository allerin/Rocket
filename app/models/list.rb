class List < ActiveRecord::Base
  belongs_to :order
  
  def self.add_to_order(order, upload)
    list = self.new(:filename => upload.original_filename, :data => upload.read)
    order.list = list
    list.save
  end
  
end
