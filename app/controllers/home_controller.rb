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
  # A class representing miscellaneous pages, eg 404s
# Author:: Simon Wilkins (si@andymayer.net)
# Copyright:: (c) 2007 andymayer.net Ltd
class HomeController < ApplicationController

  open_action :index

  # HOLDING_VIEW = "#{RAILS_ROOT}/client/app/views/home/holding.html.haml"

  HOLDING_VIEW = "home/holding"

  before_filter :set_is_home
  before_filter :render_holding_page_if_exists, :only => :index

  def index
  end

  private
  # Renders holding page if it exists, if member is NOT logged in, and the root request path is used.
  # /logged-out should render the homepage, but not the holding page
  def render_holding_page_if_exists
    if view_exists?(HOLDING_VIEW) && !@logged_in_member && request.path == '/'
      render(:template => HOLDING_VIEW, :layout => false) and return
    end
  end

  def set_is_home
    @is_home = true
  end

end
