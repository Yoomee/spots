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
module TitleHelper
  
  def hide_page_title
    @hide_page_title = true
  end
  
  def hide_page_title?
    @hide_page_title
  end
  
  def hidden_title(title, options={})
    title(title, options.merge(:hidden => true))
  end
  
  def page_subtitle
    @content_for_subtitle || @page_subtitle
  end
  
  # Get's either the result of a title call from the view, or @page_title if this is nil
  def page_title
    @content_for_title || @page_title
  end

  def subtitle(title)
    content_for(:subtitle) {title}
  end
      
  def title(title, options = {})
    hide_page_title if options[:hidden]
    content_for(:title) {title}
  end
  
  def title_here(title)
    hide_page_title
    content_for(:title) {title}
    content_tag(:h1, title, :id => 'page_title')
  end

end
