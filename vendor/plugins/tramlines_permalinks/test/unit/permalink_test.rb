require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class PermalinkTest < ActiveSupport::TestCase
  
  subject {Factory(:permalink)}
  
  should belong_to(:model)
  
  should have_db_column(:model_id).of_type(:integer)
  should have_db_column(:model_type).of_type(:string)
  should have_db_column(:name).of_type(:string)

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
    
  context "after_update" do

    setup do
      @permalink = Factory.create(:permalink, :name => "a-permalink")
      @permalink.update_attribute(:name, "another-permalink")
    end

    should "create old_permalink if name has changed" do
      assert OldPermalink.exists?(:name => "a-permalink")
    end
    
  end

  context "on call to class method replace_urls_with_permalinks" do
    
    setup do
      @page_permalink = Factory.create(:permalink, :name => "page-123", :model_type => "Page", :model_id => 123)
      @section_permalink = Factory.create(:permalink, :name => "section-123", :model_type => "Section", :model_id => 123)
    end
    
    should "replace page url" do
      text = "Some text http://sitename.com/pages/123 some more text http://sitename/pages/1234"
      replaced_text = "Some text http://sitename.com/page-123 some more text http://sitename/pages/1234"
      assert_equal replaced_text, Permalink.replace_urls_with_permalinks(text)
    end
    
    should "replace page path" do
      text = "Some text <a href='/pages/123'>Page 123</a> some more text <a href='/home'>Home</a>"
      replaced_text = "Some text <a href='/page-123'>Page 123</a> some more text <a href='/home'>Home</a>"
      assert_equal replaced_text, Permalink.replace_urls_with_permalinks(text)      
    end
    
    should "replace page and section urls" do
      text = "http://sitename.com/sections/123 some text http://sitename.com/pages/123 some more text http://sitename.com/sections/123"
      replaced_text = "http://sitename.com/section-123 some text http://sitename.com/page-123 some more text http://sitename.com/section-123"
      assert_equal replaced_text, Permalink.replace_urls_with_permalinks(text)
    end
    
    should "replace page and section paths" do
      text = "Some text <a href='/pages/123'>Page 123</a> some more text <a href='/sections/123'>Section 123</a>"
      replaced_text = "Some text <a href='/page-123'>Page 123</a> some more text <a href='/section-123'>Section 123</a>"
      assert_equal replaced_text, Permalink.replace_urls_with_permalinks(text)      
    end
    
  end
  
end
