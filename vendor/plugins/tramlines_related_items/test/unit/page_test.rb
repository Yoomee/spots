require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class PageTest < ActiveSupport::TestCase
  
  should "have related items" do
    assert Page.included_modules.include?(HasRelatedItems)
  end
  
  context "when getting related_items" do
    
    setup do
      @page, @related_page = Factory.create(:page), Factory.create(:page)
      @page.related_items << @related_page      
    end
    
    should "return all related items" do
      @section = Factory.create(:section)
      @page.related_items << @section
      assert_equal [@related_page, @section], @page.related_items
    end
    
    should "not return items that are not related" do
      assert_equal [@related_page], @page.related_items
    end
    
    context "on call to related_pages" do
      
      should "only return related pages" do
        @page.related_items << Factory.create(:section)
        assert_equal [@related_page], @page.related_pages
      end
      
    end
   
  end
  
  context "on call to has_related_items?" do

    setup do
      @page = Factory.create(:page)
    end

    should "return true if page has related items" do
      @page.related_items << Factory.create(:page)
      assert @page.has_related_items?
    end

    should "return false if no related items" do
     assert !@page.has_related_items?
    end

  end

  context "on call to has_related_pages?" do

    setup do
      @page = Factory.create(:page)
    end

    should "return true if page has related pages" do
      @page.related_items << Factory.create(:page)
      assert @page.has_related_pages?
    end

    should "return false if page has no related pages" do
      @page.related_items << Factory.create(:section)
      assert !@page.has_related_pages?
    end

  end
  
end