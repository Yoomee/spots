require File.dirname(__FILE__) + '/../../../../test/test_helper'

class TramlinesPermalinksTest < ActiveSupport::TestCase

  context "auto-update is true" do
    
    setup do
      @old_auto_update_permalink = Page.auto_update_permalink
      Page.auto_update_permalink = true
      @page = Factory.create(:page, :title => "Test page")
    end
    
    teardown do
      Page.auto_update_permalink = @old_auto_update_permalink
    end
    
    should "create a permalink when object is created" do
      assert_equal @page.permalink_name, "test-page"
    end
    
    should "update permalink when record's to_s has changed" do
      @page.update_attributes(:title => "Testing page")
      assert_equal @page.permalink_name, "testing-page"
    end
    
    should "not change permalink when record's to_s has not changed" do
      @page.update_attributes(:title => "Test page")
      assert_equal @page.permalink_name, "test-page"
    end
    
  end

end
