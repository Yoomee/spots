# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
require File.dirname(__FILE__) + '/../../../test/test_helper'
class ActivityTest < ActiveSupport::TestCase
  
  should have_db_column(:name).of_type(:string)
  should have_db_column(:description).of_type(:text)
  should have_db_column(:image_uid).of_type(:string)
  should have_db_column(:activity_type).of_type(:string)
  should have_db_column(:weight).of_type(:integer).with_options(:default => 0)
  should have_timestamps

  should have_many(:documents).dependent(:destroy)
  should have_many(:time_slots).dependent(:destroy)
  should belong_to(:organisation_group)
    
  should validate_presence_of(:name)
  
end