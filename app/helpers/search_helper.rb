module SearchHelper
  
  def search_heading(found_item, term)
    highlight(found_item.to_s, term.split)
  end
  
  def search_summary(found_item, term, options={})
    highlight(search_summary_text(found_item, term, options), term.split)
  end
  
  def search_summary_text(found_item, term, options = {})
    options.reverse_merge!(:radius => 100)
    # Loop through the summary fields until the search term is found.
    found_item.summary_fields.each do |summary_field|
      # Split term and use these to find
      term.split.each do |term_part|
        field_text = strip_video_player_urls(strip_tags(found_item.send(summary_field).to_s))
        excerpt = excerpt(field_text, term_part, options[:radius])
        return excerpt unless excerpt.nil?
      end
    end
    # If it's not found return the first summary field
    if field = found_item.summary_fields.first
      ret = strip_video_player_urls(strip_tags(found_item.send(field)))
      return ret.nil? ? '' : truncate(ret, :length => options[:radius]*2)
    else
      ''
    end
  end
  
end