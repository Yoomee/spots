require File.dirname(__FILE__) + '/../test_helper'

class TramlinesNewsFeedTest < ActiveSupport::TestCase

  context "ActiveRecord::Base" do
    
    should "have a add_to_news_feed class method" do
      assert_respond_to ActiveRecord::Base, :add_to_news_feed
    end
    
  end

end
