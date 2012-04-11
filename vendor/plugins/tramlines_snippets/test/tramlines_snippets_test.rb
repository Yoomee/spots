require File.dirname(__FILE__) + '/../../../../test/test_helper'

class TramlinesSnippetsTest < ActiveSupport::TestCase

  context "saving a page with a snippet" do
    
    setup do
      @page = Factory.build(:page)
    end
    
    should "not save snippet if text is only html tags" do
      @page.update_attribute(:snippet_pull_quote, "<br />\r\n")
      assert !@page.snippets.exists?(:name => "pull_quote")
    end
    
    should "save snippet if text not blank" do
      @page.update_attribute(:snippet_pull_quote, "Actual content")
      assert @page.snippets.exists?(:name => "pull_quote")
    end
    
  end

end
