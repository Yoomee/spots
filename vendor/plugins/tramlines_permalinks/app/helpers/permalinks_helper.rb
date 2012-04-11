module PermalinksHelper;end

ActionView::Helpers::UrlHelper.module_eval do
  
  def current_page_with_permalinks?(options)
    current_page_without_permalinks?(options) || current_page_matches_permalink?(options)
  end
  alias_method_chain :current_page?, :permalinks
  
  private
  def current_page_matches_permalink?(options)
    if options.is_a?(ActiveRecord::Base) && options.respond_to?(:permalink)
      permalink = options.permalink
      permalink ? permalink.model_path == request.request_uri : false
    else
      false
    end
  end
  
end