module TramlinesCkeditorHelper
  
  def album_options(albums)
    options_for_select albums.map {|album| [album.name, album.id]}
  end
  
end