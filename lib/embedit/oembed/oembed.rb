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
  
  class Oembed
    
    attr_reader :title, :url, :format, :html, :thumbnail
    
    def initialize(url, provider)
      @input_url = url
      get_info(provider)
    end

    def html(size = {})
      if @format == 'photo'                                                                           #Photos use image tags
        @html.insert(-2, " height=#{size[:height]} ") unless size[:height].nil?
        @html.insert(-2, " width=#{size[:width]}") unless size[:width].nil?
      else
        @html.gsub!(/height="\d+"/, %{height="#{size[:height].to_s}"}) unless size[:height].nil?
        @html.gsub!(/width="\d+"/, %{width="#{size[:width].to_s}"}) unless size[:width].nil?
      end
      @html
    end
        
    private    
    
    def get_info(provider)
      oembed_services = Providers.new.sites                   #Load the oEmbed providers - stored in ../providers/yaml
      base_url = prepare_url(oembed_services[provider])       #Prepare the base_url
      url = URI.parse(base_url + @input_url)
      api_data = Net::HTTP.get(url)                           #Get the data
      puts "DEBUG: #{api_data}"
      set_attributes(api_data)
    end
    
    def set_attributes(att)
      parsed_data = JSON.parse(att)                           
      @title = parsed_data['title']
      @url = parsed_data['url'] ||= @input_url
      @format = parsed_data['type']
      @thumbnail = parsed_data['thumbnail_url']
      @html = @format == 'video' ? parsed_data['html'] : %{<img src='#{@url}' alt='#{@title}'>}   #Image tags
    end
        
    #some urls contain format in the middle of the url
    def prepare_url(url)
      if url.match(/format/)
        return "#{url.gsub(/\{format\}/, 'json')}" + '?url='
      else
        @input_url = @input_url + '&format=json'
        return url + '?url='
      end
    end    
  end
  
end