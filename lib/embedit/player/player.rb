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
# TODO Having problems with using in rails (files not being found), need to look into. But works perfectly find with www.pandastream.com
module Embedit
  
  class Player
  
    attr_reader :title, :url, :format
    
    def initialize(url)
      @url = url
    end
            
    def html(size = {})
      self.html = @url  # Reset measurements, incase if hmtl is called twice on the same object
      @html.gsub!(/400/, size[:width].to_s) unless size[:width].nil?
      @html.gsub!(/300/, size[:height].to_s) unless size[:height].nil?
      @html
    end
    
    def html=(url)
      @html = %(<embed src="http://s3.amazonaws.com/panda-test/player.swf" width="400" height="300" 
      allowfullscreen="true" allowscriptaccess="always" 
      flashvars="&displayheight=300&file=#{url}&width=400&height=300" />)
    end
    
  end
  
end
