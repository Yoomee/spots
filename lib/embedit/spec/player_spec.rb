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

describe "JW player tests" do
   
  it "should show false on invalid path" do
    a = create_media("aslkdh/asd/asdasda").valid?
    a.should == false
  end
      
  it "should show false on invalid url" do
    a = create_media("../test.flv").valid?
    a.should == true
  end
  
  private
  
  def create_media(url)
    Embedit::Media.new(url)
  end
  
end
