class Box < ActiveRecord::Base
  
  
  def volume
    depth.to_f * width.to_f * height.to_f 
  end
end
