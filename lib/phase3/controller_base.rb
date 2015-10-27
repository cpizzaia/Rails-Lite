require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      directory = File.dirname(__FILE__)
      controller_name = self.class.name.underscore
      path = File.join(directory, "..", "..", "views", self.class.name.underscore, "#{template_name}.html.erb")
      result = File.read(path)
      render_content(ERB.new(result).result(binding), "text/html")
    end
  end
end
