require File.dirname(__FILE__) + '/../test_helper'
class SearchTest < ActiveSupport::TestCase
  
  context "a new instance with a term" do
    
    setup do
      @search = Search.new(:term => 'Test')
    end
    
    should "return the search results" do
      @results = [Factory.build(:page)]
      # It seems that using exclude_index_prefix can cause problems due to index option passed to sphinx being too long. However, it should only return a subset of the results we actually want, so shouldn't be a problem.
      #ThinkingSphinx.expects(:search).with('Test', :match_mode => :all, :exclude_index_prefix => 'autocomplete').returns @results
      # Therefore...
      ThinkingSphinx.expects(:search).with{|term, options| term=='Test' && options[:with]=={} && options[:match_mode]==:all}.returns @results
      assert_equal @results, @search.results
    end
    
    should "return the term on call to term" do
      assert_equal 'Test', @search.term
    end
    
  end
  
end
