WillPaginate::LinkRenderer.class_eval do

  def page_link_with_remote(page, text, attributes = {})
    if !@options[:update].blank?
      remote_options = {:url => url_for(page), :method => :get, :update => @options[:update], :loading => @options[:loading], :complete => @options[:complete]}
      @template.link_to_remote text, remote_options, attributes
    elsif form_id = @options[:form_id]
      @template.link_to_function(text, "TramlinesFormLinkRenderer.submit_form('##{form_id}', '#{page}')", attributes)
    else
      page_link_without_remote(page, text, attributes)
    end
  end
  
  alias_method_chain :page_link, :remote
  
end