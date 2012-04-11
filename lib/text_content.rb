# -----------------------------------------------------------------------
#
# Copyright (c) andymayer.net Ltd, 2007-2008. All rights reserved.
 
# This software was created by andymayer.net and remains the copyright
# of andymayer.net and may not be reproduced or resold unless by prior
# agreement with andymayer.net.
#
# You may not modify, copy, duplicate or reproduce this software, or
# transfer or convey this software or any right in this software to anyone
# else without the prior written consent of andymayer.net; provided that
# you may make copies of the software for backup or archival purposes
# 
# andymayer.net grants you the right to use this software solely
# within the specification and scope of this project subject to the
# terms and limitations for its use as set out in the proposal.
# 
# You are not be permitted to sub-license or rent or loan or create
# derivative works based on the whole or any part of this code
# without prior written agreement with andymayer.net.
# 
# -----------------------------------------------------------------------
module TextContent

  EMAIL_ADDRESS = /[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))/
  EMAIL_LINK_STRING = "<a href='mailto:#EMAIL#'>#EMAIL#</a>"
  EMAIL_PLACEHOLDER = /#EMAIL#/
  GOOGLE_VIDEO_PLAYER_STRING = "<p><embed class='videoPlayer' type='application/x-shockwave-flash' src='http://video.google.com/googleplayer.swf?docId=#ID#&amp;hl=en-GB' flashvars='autoPlay=true&amp;playerMode=mini'></p>" 
  GOOGLE_VIDEO_URL = /(http\:\/\/)?(video\.)?google\.co\.uk\/videoplay\?docid=([-]*[A-Za-z0-9\-_]*((&amp;)?[A-Za-z0-9\-_=]*)*(?=\s|&nbsp;|<|$))/
  ID_PLACEHOLDER = /#ID#/
  NON_QUOTE_CHARS = /[\s]|>|;/
  NON_QUOTE_CHAR_PLUS_EMAIL_ADDRESS  = /([\s]|>|;)[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))/
  NON_QUOTE_CHAR_PLUS_URL = /([\s]|^|>|;)(((file|gopher|news|nntp|telnet|http|ftp|https|ftps|sftp):\/\/)|(www\.))+(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(\/[a-zA-Z0-9\&amp;%_\.\/-~-][^<]*)?(?!['"])/
  URL = /(((file|gopher|news|nntp|telnet|http|ftp|https|ftps|sftp):\/\/)|(www\.))+(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(\/[a-zA-Z0-9\&amp;%_\.\/-~-]*)?(?!['"])/
  URL_LINK_STRING = "<a target='_new' href='#URL#'>#URL#</a>"
  URL_PLACEHOLDER = /#URL#/
  VIMEO_PLAYER_STRING = "<object width='400' height='300'><param name='allowfullscreen' value='true' /><param name='allowscriptaccess' value='always' /><param name='movie' value='http://vimeo.com/moogaloop.swf?clip_id=#ID#&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1' /><embed src='http://vimeo.com/moogaloop.swf?clip_id=#ID#&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1' type='application/x-shockwave-flash' allowfullscreen='true' allowscriptaccess='always' width='400' height='300'></embed></object>"
  VIMEO_URL = /(http\:\/\/)?(www\.)?vimeo\.com\/(\d+)/
  YOUTUBE_PLAYER_STRING = "<p><object width='425' height='350'><param name='movie' value='http://www.youtube.com/v/#ID#'></param><param name='wmode' value='transparent'></param><embed src='http://www.youtube.com/v/#ID#' type='application/x-shockwave-flash' wmode='transparent' width='425' height='350'></embed></object></p>"
  YOUTUBE_URL = /(http\:\/\/)?(.{1,3}\.)?youtube\.com\/watch\?v=([-]*[A-Za-z0-9\-_]*((&amp;)?[A-Za-z0-9\-_=]*)*(?=\s|&nbsp;|<|$))/

  class << self

    def extended(obj)
      obj.replace_urls_with_links!
      obj.replace_youtube_urls_with_embedded_players!
      obj.replace_google_video_urls_with_embedded_players!
      obj.replace_vimeo_urls_with_links!
      obj.replace_email_addresses_with_links!
    end

  end

  def replace_email_addresses_with_links!
    gsub! NON_QUOTE_CHAR_PLUS_EMAIL_ADDRESS do |shortcut_without_quotes|
      head, email_address = head_and_tail(shortcut_without_quotes)
      match = email_address.match EMAIL_ADDRESS
      head + EMAIL_LINK_STRING.gsub(EMAIL_PLACEHOLDER, $&)
    end
  end

  def replace_google_video_urls_with_embedded_players!
    player_string = GOOGLE_VIDEO_PLAYER_STRING
    gsub! GOOGLE_VIDEO_URL do |url|
      google_video_id = $3
      player_string.gsub ID_PLACEHOLDER, google_video_id
    end
  end

  def replace_urls_with_links!
    begin
      # Check that the url is not being quoted
      gsub! NON_QUOTE_CHAR_PLUS_URL do |shortcut_without_quotes|
        # Remove any whitespace at end
        whitespace_match = shortcut_without_quotes.match(/(.+)(\s*.*)/)
        shortcut_without_quotes_and_whitespace = whitespace_match[1]
        whitespace_etc = whitespace_match[2]
        # Remove first char if shortcut_without_quotes starts with anything other than RegExp ^
        if shortcut_without_quotes_and_whitespace[0, 1].match(NON_QUOTE_CHARS)
          head, url = head_and_tail(shortcut_without_quotes_and_whitespace)
        else
          head = ''
          url = shortcut_without_quotes_and_whitespace
        end
        if url.match(Regexp.union(YOUTUBE_URL, GOOGLE_VIDEO_URL, VIMEO_URL))
          # If url is a youtube or google video url do nothing
          shortcut_without_quotes
        else
          match = url.match URL
          # Standardise the url format
          url = match[3].nil? ? "http://#{match[0]}" : match[0]
          head + URL_LINK_STRING.gsub(URL_PLACEHOLDER, url) + whitespace_etc
        end
      end
    rescue
      self
    end
  end

  def replace_vimeo_urls_with_links!
    gsub! VIMEO_URL do |url|
      vimeo_id = $3
      VIMEO_PLAYER_STRING.gsub ID_PLACEHOLDER, vimeo_id
    end
  end 

  def replace_youtube_urls_with_embedded_players!
    gsub! YOUTUBE_URL do |url|
      youtube_id = $3
      YOUTUBE_PLAYER_STRING.gsub ID_PLACEHOLDER, youtube_id
    end
  end

  private
  def head_and_tail string
    head = string[0, 1]
    tail = string[1, string.length - 1]
    [head, tail]
  end

end
