class Float
    
  def to_fraction
    int, remainder = self.to_i, (self - self.to_i)
    if remainder > 0
      if fraction = @@fraction_hash[remainder]
        int.to_s + ' ' + fraction
      else
        self.to_s
      end
    else
      int.to_s
    end
  end
  
  def self.init_fraction_hash
    @@fraction_hash = (1..256).collect { |denom| 
      (1..(denom-1)).collect { |numer| 
        [(numer.to_f/denom.to_f),(numer.to_s + "/" + denom.to_s)] 
      } 
    }.
    inject({}) do |hash, denom_group| 
      denom_group.each do |fraction| 
        hash[fraction.first] ||= fraction.last 
      end
      hash
    end
  end 

  def self.fraction_hash
    @@fraction_hash
  end
  
  init_fraction_hash

end