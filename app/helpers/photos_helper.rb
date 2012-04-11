module PhotosHelper
  
  def link_to_photo_album_list
    if @photo_album && @photo_album.member
      link_if_allowed "#{forename_or_your(@photo_album.member).titleize} albums", attachable_photo_albums_proc(@photo_album.member)
    elsif @photo_album && @photo_album.attachable
      link_if_allowed "#{@photo_album.attachable}'s albums", attachable_photo_albums_proc(@photo_album.attachable)
    else
      link_if_allowed "All albums", photo_albums_proc
    end
  end
  
  def no_photo_albums_message
    if @attachable
      message = @attachable.is_a?(Member) ? "#{forename_or_you(@attachable, 'has').capitalize}" : "#{@attachable} has"
    else
      message = "There are"
    end
    message += " no photo albums yet. "
  end
  
end