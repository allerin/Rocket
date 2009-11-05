module ProductsHelper
  
  def tooltips( product, product_option, string = nil )
    
    options = ProductOptionValue.find(  :all,
                                        :select => "product_option_values.*",
                                        :joins => "LEFT JOIN products_product_option_values on product_option_values.id = products_product_option_values.product_option_value_id",
                                        :conditions => "products_product_option_values.product_id=#{product.id} and product_option_values.product_option_id=#{product_option.id}",
                                        :order => "products_product_option_values.sort_order" )    
    
    string = options.collect { |o| o.tooltip if o.tooltip and not o.tooltip.empty? }.compact.uniq.join(" <br\> ") if string.blank?
    id = generate_random_string
    link = content_tag(:a, image_tag("help-btn.jpg", :height => 18, :width => 18, :align => "right", :border => 0), :onmouseover => "toggle_visibility('#{id}');", :onmouseout => "toggle_visibility('#{id}');" )
    span = content_tag(:span, string, :class => "tooltip", :id => id, :style => "display:none")
    content_tag(:div,"#{link} #{span}", :class => "tooltip_container")
  end
  
  def quantity_options(product, selected = nil, versions = nil)
    
    product.quantity_options.inject("") do |string, option|
      
      is_selected =   if option == selected
                        " SELECTED "
                      else
                        ""
                      end   
      
      if option.to_s.length > 3 
        commified_value = option.to_s.reverse.gsub!(/(\d\d\d)(?=\d)(?!\d*\.)/, '\1,').reverse
      else
        commified_value = option
      end
      
      string << "<option value='#{option}' #{is_selected}>#{versions.to_s + " x " if versions and versions > 1} #{commified_value}</option>"
    end
  end
  
  def standard_quantities( increments = { 250 => 1000, 500 => 10000, 2500 => 50000, 5000 => 60000, 10000 => 100000, 100000 => 200000 } )
    x = 0
    qArray = []
    
    until x >= increments.values.sort.last do
      this_increment = increments.index( increments.values.sort.detect { |max_value| x < max_value } )
      qArray << ( x += this_increment) 
    end
    return qArray
  end
  
end
