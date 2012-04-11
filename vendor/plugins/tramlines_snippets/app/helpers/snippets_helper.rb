module SnippetsHelper
  
  def snippet(item, name = nil, div = true)
    if item.has_snippet?(name)
      if div
        content_tag :div, item.snippet_text(name), :class => name
      else
        item.snippet_text(name)
      end
    end
  end
  
  def site_snippet(name, div = true)
    ss = Snippet.site_snippet(name)
    return "" if ss.text.blank?
    div ? content_tag(:div, ss.text, :class => "snippet_#{name}") : ss.text
  end
  
end