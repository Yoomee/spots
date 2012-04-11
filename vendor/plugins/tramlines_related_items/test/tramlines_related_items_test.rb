require File.dirname(__FILE__) + '/../../../../test/test_helper'

class TramlinesRelatedItemsTest < ActiveSupport::TestCase

  context "ActiveRecord::Base" do
    
    should "have a has_related_items class method" do
      assert_respond_to ActiveRecord::Base, :has_related_items
    end
    
  end
  
  context "A model that has_related_items of pages and photos" do
    
    setup do
      Page.has_related_items(:pages, :photos)
      @child_page = Factory.create(:page)
      @parent_page = Factory.create(:page)
      @photo = Factory.create(:photo)
      @parent_page.related_items << [@child_page, @photo]
    end

    should "have related_items method that returns all the related items" do
      assert_equal @parent_page.related_items, [@child_page, @photo]
    end
    
    should "have related_pages method that returns the related pages" do
      assert_equal @parent_page.related_pages, [@child_page]
    end
    
    should "have related_photos method that returns the related photos" do
      assert_equal @parent_page.related_photos, [@photo]
    end
    
  end
  
end
