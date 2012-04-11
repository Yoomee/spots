module ContentHelper
  
  def description_for(object, options = {})
    options[:length] ||= 100
    description = case
      when object.respond_to?(:description)
        object.description
      when object.respond_to?(:summary)
        # Use large value for length, as it will be truncated later
        object.summary(99999)
      when object.respond_to?(:text)
        object.text
      else
        ''
    end
    # Just in case one of the above returns nil
    description ||= ''
    truncate_html(description.strip, options[:length])
  end
  
  def render_meta_tags
    return nil unless @meta_tags
    returning out = "" do
      @meta_tags.each do |name, content|
        out << content_tag(:meta, nil, :name => name, :content => content)
      end
    end
  end
  
  def meta_tags(tags)
    @meta_tags = (@meta_tags || {}).merge!(tags)
    return nil
  end
  
end