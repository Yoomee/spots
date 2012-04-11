require File.dirname(__FILE__) + '/../test_helper'
class TagTest < ActiveSupport::TestCase
  
  context "after_destroy on a tagging" do
    
    setup do
      @tag = Tag.create(:name => "test_tag")
      @tagging = @tag.taggings.create(:context => "tag")
      @tagging.destroy
    end
    
    should "delete tag if it has no other taggings" do
      assert Tag.count.zero?
    end
    
  end
  
end