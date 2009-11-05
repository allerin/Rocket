class String
  def line_from_index(index)
    lines = self.to_a
    running_length = 0
    lines.each_with_index do |line, i|
      running_length += line.length
      if running_length > index
        return i
      end
    end
  end
end

class FootnoteFilter
  def self.filter(controller)
    return if controller.render_without_footnotes
    begin
      abs_root = File.expand_path(RAILS_ROOT)
    
      # Some controller classes come with the Controller:: module and some don't (anyone know why? -- Duane)
      controller_filename = "#{abs_root}/app/controllers/#{controller.class.to_s.underscore}.rb".sub('/controllers/controllers/', '/controllers/')
      controller_text = IO.read(controller_filename)
      index_of_method = (controller_text =~ /def\s+#{controller.action_name}[\s\(]/)
      controller_line_number = controller_text.line_from_index(index_of_method) if index_of_method
    
      if controller.instance_variable_get("@performed_render")
        template = controller.instance_variable_get("@template")
        template_path = template.first_render
        template_extension = template.pick_template_extension(template_path)
        template_file_name = template.send(:full_template_path, template_path, template_extension)
        # Need the absolute path for the txmt:// urls
        template_file_name = File.expand_path(template_file_name)

        if ["rhtml", "rxhtml"].include? template_extension
          controller_url = "txmt://open?url=file://#{controller_filename}"
          controller_url += "&line=#{controller_line_number + 1}" if index_of_method
          controller.response.body += "<center>"
          controller.response.body += "TextMate Footnotes: <a href='#{controller_url}'>Controller</a>"
          controller.response.body += " | <a href='txmt://open?url=file://#{template_file_name}'>View</a>"
          controller.response.body += "</center>"
        end
      end
    rescue
      # Discard footnotes if there are any problems
    end
  end
end

class ActionController::Base
  attr_accessor :render_without_footnotes
  
  after_filter FootnoteFilter
  
protected
  alias footnotes_original_render render
  def render(options = nil, deprecated_status = nil, &block) #:doc:
    if options.is_a? Hash
      @render_without_footnotes = (options.delete(:footnotes) == false)
    end
    footnotes_original_render(options, deprecated_status, &block)
  end
end