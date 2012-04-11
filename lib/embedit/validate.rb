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
class Validate
  
  def initialize(url)
    @url = url
    @valid = check_url == true ? true : false
  end
  
  def valid?
    @valid
  end
    
  private
  
  def check_url    
    if (check_url_supported == true && check_response == true) || (File.extname(@url) != "" || nil && check_url_supported)    #We first check that the url is one actually supported by Embedit
      return true
    end
  end
  
  def check_response
    true if open(@url)    #Header codes are annoying, just check that the page works, the check with Embed::Media will narrow down more
    rescue
      false
  end
  
  def check_url_supported
    oembed_providers = Embedit::Providers.new.sites
    oembed_providers.keys.each do |key|                       #First search oembed providers for a match
      if @url.match(/(\.|\/)#{key}\./)                        #URL can be www.vimeo.com || http://vimeo.com
        return true
      end
    end
    # Now we go through all services not linked with oEmbed
    if @url.match(/(\.|\/)youtube\./)                         #All youtube links should end with a .com (Please correct if I'm wrong) they get redirected to jp.youtube.com or whatever                      
      return true 
    elsif @url.match(/share\.ovi\.com/)
      return true
    elsif File.extname(@url) != "" || nil
      return true
    end
    return false                                              #Return false if all else fail
  end
  
end
