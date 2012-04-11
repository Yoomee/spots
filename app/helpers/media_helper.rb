module MediaHelper
  
  def link_to_photo_album_list
    if @photo_album && @photo_album.member
      link_if_allowed "#{forename_or_your(@photo_album.member).titleize} albums", attachable_photo_albums_proc(@photo_album.member)
    elsif @photo_album && @photo_album.attachable
      link_if_allowed "#{@photo_album.attachable}'s albums", attachable_photo_albums_proc(@photo_album.attachable)
    else
      link_if_allowed "All albums", photo_albums_proc
    end
  end
  
  def no_media_message(options = {})
    if options[:owner]
      message = options[:owner].is_a?(Member) ? "#{forename_or_you(options[:owner], 'has').capitalize}" : "#{options[:owner]} has"
      message <<  " no #{options[:type].pluralize} yet. "
      message << link_if_allowed("Add a photo", send("new_#{options[:type]}_proc")) if options[:owner].owned_by?(@logged_in_member)
    else
      message = "No #{options[:type].pluralize} have been added yet."
    end
    message
  end
  
  def no_photo_albums_message
    if @attachable
      message = @attachable.is_a?(Member) ? "#{forename_or_you(@attachable, 'has').capitalize}" : "#{@attachable} has"
    else
      message = "There are"
    end
    message += " no photo albums yet. "
  end
  
  def media_box_options(options, type="photo")
    if options.is_a?(ActiveRecord::Base)
      options = {:owner => options, :media => options.send(type.pluralize)}
      options[:title] = (options[:owner].is_a?(Member) ? "#{forename_or_your(options[:owner]).capitalize} " : "#{options[:owner]} ") + type.pluralize.titleize
    elsif options.is_a?(Array)
      options = {:media => options}
    else
      options[:media] ||= options.delete(type.pluralize)
    end
    options.merge(:type => type)
  end
  
  def render_photos_box(options = {})
    options = media_box_options(options, "photo")
    render_media_box(options)
  end
  
  def render_media_box(options = {})
    options[:owner] ||= nil
    options[:just_photo] ||= false
    options[:title] ||= options[:type].pluralize.titleize
    render :partial => 'media/media_box', :locals => options
  end
  
  def replace_site_info(page, link, options = {})
    options[:image_size] ||= "300x"
    if link.url_error?
      page[:link_message_box].show
    else
      page["link_image_#{link.id}"].replace_html(link_to(image_for(link, options[:image_size]), link.url, :target => "_blank"))
      page["link_title_#{link.id}"].replace_html(link_to(link.title, link.url, :target => "_blank"))
      page["link_description_#{link.id}"].replace_html(link.description)
    end
  end
  
  def save_site_info_javascript(link, options = {})
    remote_function(:url => save_info_link_path(link, options), :method => :put, :loading => "$('#link_info_loader_#{link.id}').show()", :complete => "$('#link_info_loader_#{link.id}').hide()")
  end
  
end