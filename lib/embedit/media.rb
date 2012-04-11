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
  
  class Media
    
    attr_reader :title, :url, :format, :html, :thumbnail
    
    def initialize(url)
      @valid = true                                                 #Innocent until proven guilty
      @oembed_providers = Providers.new.sites
      find_provider(url)
      #rescue                                                        #Horrible hack, but flickrs poor status headers == :( 
      #  @valid = false                                              #if it breaks, its gotta be invalid, I suggest removing when debugging                                                 
    end
    
    def title
      @media_data.title
    end
    
    def html(size = {})
      @media_data.html(size)
    end
    
    def format
      @media_data.format
    end
    
    def thumbnail
      @media_data.thumbnail
    end
    
    def url
      @media_data.url
    end
    
    def valid?
      @valid    
    end
    
         
    private    

  #Find a provider
    def find_provider(url)
      return @valid = false unless Validate.new(url).valid?

      @oembed_providers.keys.each do |key|                               #First search oembed providers for a match
        if url.match(/(\.|\/)#{key}\./)                                  #URL can be www.vimeo.com || http://vimeo.com
          return @media_data = Oembed.new(url, key)
        end
      end
      if url.match(/(\.|\/)youtube\./)                                  #Next up is YouTube
        return @media_data = YouTube.new(url)
      elsif url.match(/share\.ovi\.com/)
        return @media_data = Ovi.new(url)
      elsif File.extname(url) != "" || nil
        return @media_data = Player.new(url)
      end
        @valid = false
    end
  end
end
