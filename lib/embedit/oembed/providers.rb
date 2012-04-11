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
  class Providers
    
    attr_accessor :sites
    
    def initialize
      @sites = {}
      add_default_providers
    end
    
    private
    def add_default_providers
      load_providers
    end
    
    def load_providers
      providers = YAML.load_file("#{File.dirname(__FILE__)}/providers.yaml")
      providers.each {|d| @sites.merge!(d[0] => d[1])}
    end
  end
end
