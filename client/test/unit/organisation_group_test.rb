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
class OrganisationGroupTest < ActiveSupport::TestCase
  
  should have_db_column(:description).of_type(:text)  
  should have_db_column(:image_uid).of_type(:string)
  should have_db_column(:name).of_type(:string)
  should have_timestamps
  
  should have_many(:organisations)
  
  should validate_presence_of(:name)
  
  context "find_by_ref" do
    should "return nil if ref blank" do
      assert_nil OrganisationGroup.find_by_ref("")
    end
    
    should "return nil if ref nil" do
      assert_nil OrganisationGroup.find_by_ref(nil)
    end
  end
  
  context "an instance" do

    setup do
      @organisation_group = Factory.create(:organisation_group, :id => 1)
    end
    
    should "have a ref method" do
      assert_respond_to @organisation_group, :ref
    end
    
    should "generate Base64 ref" do
      assert_equal Base64.encode64((@organisation_group.id+1000).to_s).strip.sub(/\=*$/,''), @organisation_group.ref
    end
    
    should "be findable by its ref" do
      assert_equal @organisation_group, OrganisationGroup.find_by_ref(@organisation_group.ref)
    end
    
    should "be findable by its ref with bigger IDs" do
      [10,123,1000,12345, 100000].each do |num|
        organisation_group = Factory.create(:organisation_group, :id => num)
        assert_equal organisation_group, OrganisationGroup.find_by_ref(organisation_group.ref)
      end
    end
    
  end
  
end
