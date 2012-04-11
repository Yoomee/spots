# Include hook code here
# require the controller
require 'dispatcher'
config.to_prepare do
  require_dependency File.dirname(__FILE__) + '/app/controllers/ckeditor_controller'
end


module ActionView::Helpers::AssetTagHelper
  
  def javascript_include_tag_with_ckeditor_source(*sources)
    main_sources, application_source = [], []
    if sources.include?(:ckeditor_source)
      sources.delete(:ckeditor_source)
      sources.push('ckeditor/ckeditor_source')
    end
    unless sources.empty?
      main_sources = javascript_include_tag_without_ckeditor_source(*sources).split("\n")
      application_source = main_sources.pop if main_sources.last.include?('application.js')
    end
    [main_sources.join("\n"), application_source].join("\n")
  end
  alias_method_chain :javascript_include_tag, :ckeditor_source
  
end
