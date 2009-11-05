class DesignOption < ActiveRecord::Base
  has_many :design_option_values
  
  ## Takes a hash like { 'option_label' => 'value_label' } (i.e. what we get from form params) 
  ## and replaces the strings with the actual activerecord objects.
  def self.soft_to_raw( soft_options )
    raw_options = {}
    soft_options.each do | option_label, value_label |
      if option = self.find(:first, :conditions => "label = '#{option_label}'")
        if value = option.design_option_values.find( :first, :conditions => "label = '#{value_label}'")
          raw_options[ option ] = value
        end
      end
    end
    return raw_options
  end
  
  def self.proof_price
    self.find( :first, :conditions => "label = 'proof'").design_option_values.find( :first, :conditions => "label = 'true'" ).setup_price
  end
  
end
