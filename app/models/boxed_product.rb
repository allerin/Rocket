class BoxedProduct < ActiveRecord::Base
  belongs_to :box
  belongs_to :product
  belongs_to :coating, :class_name => "ProductOptionValue", :foreign_key => "coating_id"
  belongs_to :folding, :class_name => "ProductOptionValue", :foreign_key => "folding_id"
  
  attr_accessor :soft_options
  
  def initialize(attributes = nil)
    @soft_options = {}
    super
  end
  
  def quantity_inside
    ( @quantity_inside if @quantity_inside ) || self.max_quantity
  end
  
  def quantity_inside=(q)
    @quantity_inside = q
  end
  
  ## This lets us conveniently access certain attributes of the actual box we're using here.
  def method_missing( meth, *args)
    begin
      super
    rescue
      begin
        self.box.send meth, *args
      rescue
        super
      end
    end
  end
  
  def packed_weight
    self.box.weight + self.product.weight_for( quantity_inside, soft_options )
  end
  
end
