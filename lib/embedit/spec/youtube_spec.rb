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

describe "YouTube tests" do
  
  it "should show true on valid url" do
    a = create_media("http://www.youtube.com/watch?v=j3TOT1lnVTA").valid?
    a.should == true
  end
  
  it "should have the title of 'Best robot dance ever'" do
    a = create_media("http://www.youtube.com/watch?v=j3TOT1lnVTA").title
    a.should == 'Best robot dance ever'
  end
  
  it "should show format as video" do
    a = create_media("http://www.youtube.com/watch?v=j3TOT1lnVTA").format
    a.should == 'video'
  end
  
  it "should show false on invalid url" do
    a = create_media("http://www.youtube.com/watch?v=j3TOT1lnVTWWWWWWA").valid?
    a.should == false
  end
  
  private
  
  def create_media(url)
    Embedit::Media.new(url)
  end
  
end