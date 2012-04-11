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
require File.dirname(__FILE__) + '/spec_helper.rb'

describe "Ovi tests" do
  
  it "should show video format for video" do
    create_media('http://share.ovi.com/media/DefragTV.public/DefragTV.10014').format.should == 'video'
  end
  
  it "should show video title as 'NetworkWorld Talks Automatic Defrag'" do
    create_media('http://share.ovi.com/media/DefragTV.public/DefragTV.10014').title.should == 'NetworkWorld Talks Automatic Defrag'
  end
  
  it "should show audio format for audio" do
    create_media('http://share.ovi.com/media/ekki808.mu-sick/ekki808.10001').format.should == 'audio'
  end
  
  it "should show audio title as 'mon'" do
    create_media('http://share.ovi.com/media/ekki808.mu-sick/ekki808.10001').title.should == 'mon'
  end
  
  it "should show photo format for photo" do
    create_media('http://share.ovi.com/media/james___.public/james___.10016').format.should == 'photo'
  end
  
  it "should show photo title as 'Tom Arnold at Westbury'" do
    create_media('http://share.ovi.com/media/james___.public/james___.10016').title.should == 'Tom Arnold at Westbury'
  end
  
  private
  
  def create_media(url)
    Embedit::Media.new(url)
  end
  
end