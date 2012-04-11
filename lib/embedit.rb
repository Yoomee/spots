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
require 'rubygems'
require 'json'
require 'rexml/document'
require 'net/http'
require 'open-uri'
require 'yaml'

#Files
require File.dirname(__FILE__) + '/embedit/oembed/providers'
require File.dirname(__FILE__) + '/embedit/media'
require File.dirname(__FILE__) + '/embedit/oembed/oembed'
require File.dirname(__FILE__) + '/embedit/youtube/youtube'
require File.dirname(__FILE__) + '/embedit/ovi/ovi'
require File.dirname(__FILE__) + '/embedit/exceptions'
require File.dirname(__FILE__) + '/embedit/validate'
require File.dirname(__FILE__) + '/embedit/player/player'

# Oembed
#puts a = Embedit::Media.new('http://www.vimeo.com/1260077').title

#puts b = Embedit::Media.new('http://www.flickr.com/photos/reddavis999/2692043113/').html #valid? #.valid #.html(:height => 200)

#puts c = Embedit::Media.new('http://www.viddler.com/explore/winelibrarytv/videos/147/').format #html(:height => 200, :width => 500)

#puts d = Embedit::Media.new('http://qik.com/video/141977').html(:height => 50)

#puts e = Embedit::Media.new('http://pownce.com/dburka/notes/2951118/').html(:height => 200)

#puts f = Embedit::Media.new('http://revision3.com/trs/blockoland/').html(:height => 500)

# YouTUBE

#puts g = Embedit::Media.new("http://www.youtube.com/watch?v=j3TOT1lnVTA").html

# OVI

#puts a = Embedit::Media.new('http://share.ovi.com/media/PangeaDay.TEDTalks/PangeaDay.10054').html(:height => 900, :width => 100)

#puts b = Embedit::Media.new('http://share.ovi.com/media/DefragTV.public/DefragTV.10014').html#(:height => 900, :width => 100)

#puts c = Embedit::Media.new('http://share.ovi.com/media/james___.public/james___.10016').html(:height => 900, :width => 100)

# Flash Player

#puts a = Embedit::Media.new('../test.flv').html

#puts File.exists?(File.expand_path('test.flv'))