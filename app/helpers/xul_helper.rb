module XulHelper
  
  def replace_xul_element_old_old( element_id, xml_string )
    #xml_string.gsub!("\n", "")
    #xml_string.gsub!("\t", "")
    "$('#{element_id}').parentNode.replaceChild(xul_element_from_xml_element(element_from_string(#{xml_string.dump})), $('#{element_id}'));"
  end
  
  def replace_xul_element_old( element_id, xml_string )
    "xul_element = #{xml_string.dump}.to_e().to_xul(); " +
    "$('#{element_id}').parentNode.replaceChild(xul_element, $('#{element_id}));"
  end
  
  def replace_xul_element(element_id, xml_string)
    "$('#{element_id}').replace(#{xml_string.dump});"
  end
  
end