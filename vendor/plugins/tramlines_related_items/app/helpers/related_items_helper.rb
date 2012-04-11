module RelatedItemsHelper
  
  def render_related_items(object, options = {})
    options.reverse_merge!(:image_size => "145x90#", :limit => 3, :truncate_length => 50, :exclude_types => [""])
    if options[:only]
      related_items = object.send("related_#{options[:only].to_s}").limit(options[:limit])
    else
      related_items = object.related_items.excluding_related_types(options[:exclude_types]).limit(options[:limit])
    end
    render :partial => "related_items/related_items", :locals => {:related_items => related_items}.merge(options)
  end
  
  def render_related_items_form(object)
    render :partial => "related_items/form", :locals => {:object => object}
  end
  
end