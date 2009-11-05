module TModelSecurityHelper
  
  def secure_text_field( real_object, method, name, options = {} )
    
    if real_object.can_read?( method ) and real_object.can_write?( method )
      return text_field_tag( name, real_object.send( method.to_sym ), options  )
    elsif real_object.can_read?( method )
      return real_object.send( method.to_sym )
    end
    
  end
  
  def secure_text_area(real_object, method, name, options = {})
    if real_object.can_read?( method ) and real_object.can_write?( method )
      return text_area_tag( name, real_object.send( method.to_sym ), options  )
    elsif real_object.can_read?( method )
      return real_object.send( method.to_sym )
    end
  end
  
  def secure_select( real_object, method, name, choices, options = {})
    
    if real_object.can_read?( method ) and real_object.can_write?( method )
      return select_tag( name, options_for_select(choices, real_object.send( method.to_sym)), options)
    elsif real_object.can_read?( method )
      if actual_value = real_object.send( method.to_sym )
        selected_pair = choices.find { | choice | choice.last.to_s == actual_value.to_s }
        return selected_pair.first.to_s if selected_pair
      end
    end
  end
  
  def secure_check_box( real_object, method, name, checked = false, options = {} )
  
    if real_object.can_read?( method ) and real_object.can_write?( method )
      return check_box_tag( name, 1, checked, options ) 
    elsif real_object.can_read?( method )
      return check_box_tag( name, 1, checked, { :disabled => "disabled" }.merge(options) )
    end
    
  end

  def secure_radio_button( real_object, method, name, value, checked = false, options = {} )
    if real_object.can_read?( method ) and real_object.can_write?( method )
      return radio_button_tag( name, value, checked, options )
    elsif real_object.can_read?( method )
      return radio_button_tag( name, value, checked, { :disabled => "disabled" }.merge(options) )
    end
  end

end

