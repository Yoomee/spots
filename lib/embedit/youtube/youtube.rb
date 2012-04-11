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
module Embedit

  class YouTube
  
    attr_reader :title, :url, :format, :thumbnail
  
    def initialize(url)
      @format = 'video'
      @url = url
      get_info
    end
    
    def html(size = {})
      @html.gsub!(/height="\d+"/, %{height="#{size[:height].to_s}"}) unless size[:height].nil?
      @html.gsub!(/width="\d+"/, %{width="#{size[:width].to_s}"}) unless size[:width].nil?
      @html
    end
    
    def html=(video_id)
      #Add &ap=%2526fmt%3D18 to end of YouTube embed url to gain access to higher quality videos
      @html = %{
        <object width="425" height="350">
          <param name="movie" value="http://www.youtube.com/v/#{video_id}"></param>
          <param name="wmode" value="transparent"></param>
          <embed src="http://www.youtube.com/v/#{video_id}" 
            type="application/x-shockwave-flash" wmode="transparent" 
            width="425" height="300">
          </embed>
        </object>
      }
    end
    
    def thumbnail
      REXML::XPath.match(@data, "//media:thumbnail").first.attributes['url']
    end
        
    private
    
    def get_info
      video_id = extract_id(@url)
      @data = REXML::Document.new(open("http://gdata.youtube.com/feeds/videos/#{video_id}"))
      @title = REXML::XPath.first(@data, "//title").text
      self.html = video_id
    end
    
    def extract_id(url)
      url.scan(/v=([\w|-]+)/)
    end
  
  end

end
