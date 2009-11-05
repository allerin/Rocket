# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include XulHelper
  
  def selected_string( test )
    if test
      " selected='selected' "
    else
      ""
    end
  end
  
  def checked_string( test )
    if test
      "checked='checked'"
    else
      ""
    end
  end
  
  def yes_no_string( test )
    if test
      "Yes"
    else 
      "No"
    end
  end
  
  def dimensions_nice( width, height )
    first, second = [ width.to_f, height.to_f ].sort
    first.to_s.chomp('.0') + " x " + second.to_s.chomp('.0')
  end
  
  def link_to_sort( title, sort_column, sort_column_rev = nil)
    content = "<li class='sortOption'>"
    current_sort = (params[:sort] or session[:orders_sort])
    if current_sort == sort_column and sort_column_rev
      content << link_to_function(title, remote_function(:url => advanced_order_search_url(:sort => sort_column_rev), :with => "Form.serialize('search_form')"))
    else
      content << link_to_function(title, remote_function(:url => advanced_order_search_url(:sort => sort_column), :with => "Form.serialize('search_form')"))
    end
    content << "</li>"        			
  end

def link_to_design_sort( title, sort_column, sort_column_rev = nil)
    content = "<li class='sortOption'>"
    current_sort = (params[:sort] or session[:orders_sort])
    if current_sort == sort_column and sort_column_rev
      content << link_to_function(title, remote_function(:url => list_design_orders_url(:sort => sort_column_rev), :with => "Form.serialize('search_form')"))
    else
      content << link_to_function(title, remote_function(:url => list_design_orders_url(:sort => sort_column), :with => "Form.serialize('search_form')"))
    end
    content << "</li>"        			
  end

  def format_cc_exp(month, year)
    return '' unless month and not month.zero? and year and not year.zero?
    
    month_s = if month.to_s.length == 1
               "0" + month.to_s
              else
                month.to_s
              end
              
    year_s =  if year.to_s.length == 1
                "200" + year.to_s
              else
                "20" + year.to_s
              end
              
    month_s + "/" + year_s           
  end
  
  def select_month( name, selected_month = nil )
    string = "<select name='#{name}' id='#{name}'>"
    12.times do | month |
			month += 1
			month_value =month.to_s
	 		month = "0" + month.to_s if month < 10
	 		
	 		selected = (" selected='selected' " if month.to_s == selected_month.to_s) or ""
	    string += "<option value='#{month_value}' #{selected}>#{month}</option>"
		end
		string += "</select>"
  end
  
  def select_year( name, selected_year = nil)
    string = "<select name='#{name}' id='#{name}'>"
    10.times do | increment | 
			year = Time.now.year + increment
			selected = (" selected='selected' " if year.to_s == selected_year.to_s ) or ""
			string += "<option value='#{year}' #{selected}>#{year}</option>"
		end
		string += "</select>"
  end
  
  # Returns a link that'll submit a form, including it's onsubmit handler, 
  #  using the onclick handler and return false after the fact.
  #
  # Examples:
  #   link_to_formsubmit "Submit", "myform"
  #   link_to_formsubmit(image_tag("submit"), "1")
  def link_to_formsubmit(name, id, html_options = {})  
  	link_to_function(name, "if(document.forms['#{id}'].onsubmit()) { document.forms['#{id}'].submit(); }", html_options)
  end
  

	def record_table(columns, results, pages, update,  url = {}, 
	                  loading = nil, complete = nil, sort = true)
		row = ''
		columns.each { |column| row += content_tag( 'th', sort ? link_to_remote( column[:label], 
		                                                  :update => 'application', 
		                                                  :url=>{ :sort => column[:field] }, 
		                                                  :loading => loading, 
		                                                  :complete => complete) : column[:label], 
		                                                  :class => params[:sort] == column[:field] ? "selected" : nil ) }
		                                            
		tablehead = content_tag('thead', content_tag('tr', row))

		tablebody = ''		
		count = 0
		
		for result in results
			row = ''
			count += 1
			url.update(:page => (pages.current_page.offset + count)) if pages
			#url.update(:page => pages ? (pages.current_page.offset + count) : nil)
			for column in columns
				data = result[column[:field]]
				data = format_date(data) if column[:format] == "datetime"
				data = number_to_currency(data) if column[:format] == "currency"
				data = link_to data.to_s, url.update(:id => result[:id])
#					:update => update,
#					:url=>url,
#					:loading => loading,
#					:complete => complete
				row += content_tag('td', data)
			end
			tablebody += content_tag('tr', row, { :id => 'row_' + count.to_s })
		end
		tablebody = content_tag('tbody', tablebody)
		
		return content_tag('table', tablehead + tablebody)
	end

	def pagination_links_remote(paginator, options={})
		options.merge!(ActionView::Helpers::PaginationHelper::DEFAULT_OPTIONS) {|key, old, new| old}
		window_pages = paginator.current.window(options[:window_size]).pages

		return if window_pages.length <= 1 unless options[:link_to_current_page]

		first, last = paginator.first, paginator.last
		returning html = '' do
			if paginator.current.number != 1
				power_count = Math.log10(paginator.current.number - 1).floor
				until power_count < 0
					html << link_to_remote("&lt;" * (power_count + 1), 
						:update => options[:update], 
  						:loading => options[:loading], 
  						:complete => options[:complete], 
  						:url => { :page => paginator.current.number - (10 ** power_count) }.update( options[:params]))
					html << ' '
					power_count -= 1
				end
			end

			if options[:always_show_anchors] and not window_pages[0].first?
				html << link_to_remote(first.number, 
					:update => options[:update], 
					:loading => options[:loading], 
  					:complete => options[:complete], 
  					:url => { :page => first }.update(options[:params]))

				html << ' ... ' if window_pages[0].number - first.number > 1
				html << ' '
			end

			window_pages.each do |page|
				if paginator.current == page && !options[:link_to_current_page]
					html << page.number.to_s
				else
					html << link_to_remote(page.number, 
						:update => options[:update], 
  						:loading => options[:loading], 
  						:complete => options[:complete], 
  						:url => { :page => page }.update( options[:params]))
				end
				html << ' '
			end

			if options[:always_show_anchors] && !window_pages.last.last?
				html << ' ... ' if last.number - window_pages[-1].number > 1
				html << link_to_remote(last.number, 
  					:update => options[:update], 
  					:loading => options[:loading], 
 					:complete => options[:complete], 
  					:url => { :page => last }.update( options[:params]))
			end

			power_count = 0;
			until 10 ** power_count > paginator.last.number - paginator.current.number
				html << ' '
				html << link_to_remote("&gt;" * (power_count + 1), 
  							    :update => options[:update], 
  							    :loading => options[:loading], 
  							    :complete => options[:complete], 
  							    :url => { :page => paginator.current.number + (10 ** power_count) }.update( options[:params]))
  				power_count += 1
			end
		end #match to "do" above
	end
	
	#just keeping this around for now in case I need to rewrite it without UJS
	def pagination_links_unobtrusive_DEPRECATED(paginator, options={}) 
		options.merge!(ActionView::Helpers::PaginationHelper::DEFAULT_OPTIONS) {|key, old, new| old}
		window_pages = paginator.current.window(options[:window_size]).pages

		return if window_pages.length <= 1 unless options[:link_to_current_page]

		first, last = paginator.first, paginator.last
		returning html = '' do
			if paginator.current.number != 1
				power_count = Math.log10(paginator.current.number - 1).floor
				until power_count < 0
				  this_page = paginator.current.number - ( 10 ** power_count )
					
					html << link_to("&lt;" * (power_count + 1), 
					    { :page => this_page }.update( options[:params]),
              :id => "pagination_arrow_#{this_page}" )
					html << ' '
					
					html << apply_script(:inline) { | page | 
					  page.get("pagination_arrow_#{this_page}").
					    link_to_remote  :url => { :page => this_page }.update( options[:params] ),
					                    :update => options[:update],
					                    :loading => options[:loading],
					                    :complete => options[:complete]
					  page << "$('pagination_arrow_#{this_page}').href = '#';"
					}
					power_count -= 1
				end
			end

			if options[:always_show_anchors] and not window_pages[0].first?
        
        html << link_to(first.number,
                { :page => first }.update(options[:params]),
                :id => "pagination_link_first")
				html << ' ... ' if window_pages[0].number - first.number > 1
				html << ' '
				
				html << apply_script(:inline) { |page|
				  page.get("pagination_link_first").
				    link_to_remote  :url => { :page => first }.update(options[:params]),
				                    :update => options[:update],
				                    :loading => options[:loading],
				                    :complete => options[:complete]
				  page << "$('pagination_link_first').href = '#';"
				}
			end

			window_pages.each do |page|
				if paginator.current == page && !options[:link_to_current_page]
					html << page.number.to_s
				else
				  html << link_to(page.number,
				                  { :page => page.number }.update( options[:params]),
				                  :id => "pagination_link_#{page.number}")
				  
				  html << apply_script(:inline) { |p|
				    p.get("pagination_link_#{page.number}").
				      link_to_remote  :url => { :page => page }.update(options[:params]),
				                      :update => options[:update],
				                      :loading => options[:loading],
				                      :complete => options[:complete]
				    p << "$('pagination_link_#{page.number}').href = '#';"
				  }    
				end
				html << ' '
			end

			if options[:always_show_anchors] && !window_pages.last.last?
				html << ' ... ' if last.number - window_pages[-1].number > 1
			  html << link_to(  last.number,
			                    { :page => last.number }.update( options[:params]),
			                    :id => "pagination_link_last" )
			  
			  html << apply_script( :inline ) { | page |
			    page.get("pagination_link_last").
			      link_to_remote  :url => { :page => last.number }.update( options[:params]),
			                      :update => options[:update],
			                      :loading => options[:loading],
			                      :complete => options[:complete]
			  page << "$('pagination_link_last').href = '#';"
			  }
			
			end

			power_count = 0;
			until 10 ** power_count > paginator.last.number - paginator.current.number
			  this_page = paginator.current.number + (10 ** power_count )
				html << ' '
        html << link_to(  "&gt;" * (power_count + 1), 
                          { :page => this_page }.update( options[:params]),
                          :id => "pagination_arrow_#{this_page}")
  
        html << apply_script( :inline ) { | page |
          page.get("pagination_arrow_#{this_page}").
            link_to_remote  :url => { :page => this_page }.update( options[:params]),
                            :update => options[:update],
                            :loading => options[:loading],
                            :complete => options[:complete]
                            
        page << "$('pagination_arrow_#{this_page}').href = '#';"
        }
  			power_count += 1
			end
		end #match to "do" above
	end

	def onchange_input_helper (helper, options, url)
		
      object_name, method_name = options[:object].dup.to_s, options[:method].dup.to_s
      if object_name.sub!(/\[\]$/,"")
        auto_index = instance_variable_get("@#{Regexp.last_match.pre_match}").id_before_type_cast
      end
		
 		options[:options] ||= {}
		name =  "#{object_name}_#{auto_index}_#{method_name}"
		
		loading = update_element_function(name + '_status', 
							:content => image_tag('status_loading.gif', :size=>'16x16')) + ";"
		loading += visual_effect(:appear, name + '_status', :duration => 0)
		
		success = nil;
		
		complete = "eval(request.responseText);"
		complete += update_element_function(name + '_status', 
							:content => image_tag('status_success.gif', :size=>'16x16')) + ";"
		complete += visual_effect(:fade, name + '_status', :duration => 1)

		failure = update_element_function(name + '_status', 
							:content => image_tag('status_failure.gif', :size=>'16x16')) + ";"
		failure += visual_effect(:fade, name + '_status', :duration => 1)

		onchange = remote_function(
			  			:url => url,
			  			:with => "Form.Element.serialize(this)",
			  			:method => "'post'",
			  			:loading => loading,
			  			:complete => complete,
			  			:failure => failure)
		
		if helper == "select"
			options[:html_options].update(:onchange => onchange)
			input_html = eval helper + "(options[:object], options[:method], options[:options], options[:html_options])"
		else
			options[:options].update(:onchange => onchange)
			input_html = eval helper + "(options[:object], options[:method], options[:options])"
		end
		
		return input_html + " " + content_tag("div", image_tag('blank.gif', {:height=>"16", :width=>"16"}), {:id=>name + "_status", :class=>"field"})
	end

		
	#Standard Date Formatting
  def format_date(time)
    return time.strftime("%b %d, %Y") if time.respond_to?(:strftime)
  end
  
  def format_date_time(time)
    return '' unless time.respond_to? :strftime
    time.strftime("%b %d, %Y at %I:%M:%S %p") 
  end
      
  def pub_date(time)
    time.strftime "%a, %e %b %Y %H:%M:%S %Z"
  end

  def show_system_messages
    if flash[:error]
      return content_tag("p", flash[:error], :class => "error")
    elsif flash[:notice]
       return content_tag("p", flash[:notice], :class => "notice")
     end
  end
  
  def product_options_select( product, product_option, selected, all = false, style = "")    
    
    selected = selected.label if selected and not selected.kind_of?(String)
    
    is_normal_option = product.product_options.include?(product_option)
    
    options = (all or not is_normal_option) ? product_option.product_option_values : 
                    product.product_option_values_for_product_option( product_option )
    
    string = "<select id='product_options_#{product_option.title.downcase}' name='product_options[#{product_option.title.downcase}]' style='font-size:8pt; #{style}'>"
  
    options.each do | option |
    
      label = if option.customer_label.nil? or option.customer_label.empty?
                option.label
              else
                option.customer_label
              end
                  
      is_selected = if option.label == selected
                      " SELECTED "
                    else
                      ""
                    end
                  
      string << "<option value='#{option.label}' #{is_selected}>#{label}</option>\n"
    end
    string << "</select>"
  end
  
  def design_options_select( design_option, selected = nil)
    if design_option.kind_of?( String ) or design_option.kind_of?( Symbol )
      design_option = DesignOption.find( :first, :conditions => "label = '#{design_option.to_s}'")
    end
        
    option_values = design_option.design_option_values.find(:all, :order => '`default` DESC, customer_label')
    
    string = "<select id='#{design_option.label.downcase}' name='design_options[#{design_option.label.downcase}]' style='font-size:8pt'>"
    
    option_values.each do |ov|
      
      is_selected = ""
      if selected
        if ov.label.to_s == selected.to_s
          is_selected = " SELECTED "
        end
      else
        is_selected = " SELECTED " if ov.default
      end
        
      string << "<option value='#{ov.label}' #{is_selected}>#{ov.customer_label}</option>\n"
    end
    string << "</select>"
  end
  
  def package_options_select( name, product, product_option, selected )    
    
    options = product.product_option_values_for_product_option( product_option )
    string = "<select id='#{name}' name='#{name}' style='font-size:8pt'>"
  
    options.each do | option |
    
      label = if option.customer_label.nil? or option.customer_label.empty?
                option.label
              else
                option.customer_label
              end
                  
      is_selected = if option.label == selected
                      " SELECTED "
                    else
                      ""
                    end
                  
      string << "<option value='#{option.id}' #{is_selected}>#{label}</option>\n"
    end
    string << "</select>"
  end
  
  def link_to_modal(name, options = {}, html_options = {})
    url = options.is_a?(String) ? options : self.url_for(options)
    modal_url = html_options[:modal_url] ? 
                  (html_options[:modal_url].is_a?(String) ? html_options[:modal_url] : self.url_for(html_options[:modal_url])) : 
                  url
    modal_options = { :onclick => "$A(document.getElementsByTagName('embed')).each(function(embed){if (embed.type=='application/x-shockwave-flash') embed.StopPlay(); }); Modalbox.show('#{html_options[:modal_title]}', '#{modal_url}', {height: #{html_options[:height] || 400}, width: #{html_options[:width] || 400}}); return false;", :modal_url => nil, :modal_title => nil }
    link_to(name, url, html_options.update(modal_options))
  end
  
  def link_to_signin(name, options = {}, html_options = {})
    url = options.is_a?(String) ? options : self.url_for(options)
    if @current_customer
  		link_to name, url, html_options
  	else
  		link_to_modal(name, url, 
  									:modal_url => customer_signin_modal_url(:redirect_to => url),
  									:modal_title => 'SIGN-IN',
  									:height => 320)
  	end
  end
	
	def states_array(none_option = false, none_text = '')
	  states = [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["Arkansas", "AR"], ["Armed Forces Americas", "AA"], ["Armed Forces Europe", "AE"], ["Armed Forces Pacific", "AP"], ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["D.C.", "DC"], ["Delaware", "DE"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Iowa", "IA"], ["Kansas", "KS"], ["Kentucky", "KY"], ["Louisiana", "LA"], ["Maine", "ME"], ["Maryland", "MD"], ["Massachusetts", "MA"], ["Michigan", "MI"], ["Minnesota", "MN"], ["Mississippi", "MS"], ["Missouri", "MO"], ["Montana", "MT"], ["Nebraska", "NE"], ["Nevada", "NV"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], ["Ohio", "OH"], ["Oklahoma", "OK"], ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Puerto Rico", "PR"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Vermont", "VT"], ["Virginia", "VA"], ["Washington", "WA"], ["West Virginia", "WV"], ["Wisconsin", "WI"], ["Wyoming", "WY"]]
  states.insert(0, [none_text, nil]) if none_option
  states
  end
  
  def skus_array(none_option= true)
    skus = Product.find(:all, :select => 'DISTINCT sku', :order => 'sku', :conditions => "sku != ''").collect(&:sku)
    skus.insert(0,nil) if none_option
    skus
  end
  
  def payment_types_array(none_option = true)
    types = AbstractPayment.find(:all, :select => "DISTINCT type", 
                                 :order => 'type').collect { |p| [p.class.to_s.gsub('Payment', ''), p.class.to_s] }
    types.insert(0,nil) if none_option
    types
  end
  
  def statuses_array(none_option = true)
    statuses = Order.statuses
    statuses.insert(0,nil) if none_option
    statuses
  end
  
  def design_statuses_array(none_option = true)
    statuses = DesignOrder.statuses
    statuses.insert(0,nil) if none_option
    statuses
  end
  
  #Magnolia style buttons
  def add_default_styling(button_class)
    button_class ||= "green"
    button_class.insert(0, "button ")
  end
  
  # Added by SUHAS to change the color of TABs from Reports tab -  - Sept 8, 2008
  def add_default_styling_selected(button_class)
    button_class ||= "#3300FF"
    button_class.insert(0, "button ")
  end
  
  def mag_button_to(name, options = {}, html_options = {})
    html_options[:class] = add_default_styling(html_options[:class])
    name.gsub!(/\s/, "&nbsp;")
    link_to("<span>#{name}</span>", options, html_options)
  end
  
  def mag_button_to_function(name, function="void(0)", html_options = {})
    html_options[:class] = add_default_styling(html_options[:class])
    name.gsub!(/\s/, "&nbsp;")
    link_to_function("<span>#{name}</span>", function, html_options)
  end

  def mag_button_to_confirm(text, url, confirm_options = {}, html_options = {})
    html_options[:class] = add_default_styling(html_options[:class])
    text.gsub!(/\s/, "&nbsp;")
    link_to_confirm("<span>#{text}</span>", url, confirm_options, html_options)
  end

  def mag_button_to_confirm_function(text, function, confirm_options = {}, html_options = {})
    html_options[:class] = add_default_styling(html_options[:class])
    text.gsub!(/\s/, "&nbsp;")
    link_to_confirm_function("<span>#{text}</span>", function, confirm_options, html_options)
  end
  
  def mag_button_to_remote(name, options = {}, html_options = {})  
    html_options[:class] = add_default_styling(html_options[:class])
    name.gsub!(/\s/, "&nbsp;")
    link_to_function("<span>#{name}</span>", remote_function(options), html_options)
  end

  # Added by SUHAS to change the color of TABs from Reports tab - Sept 8, 2008
  def mag_button_to_remote_selected(name, options = {}, html_options = {})  
    html_options[:class] = add_default_styling_selected(html_options[:class])
    name.gsub!(/\s/, "&nbsp;")
    link_to_function("<span>#{name}</span>", remote_function(options), html_options)
  end
  
  def generate_random_string(size = 5)
    s = ""
    size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    s
  end
  
end
