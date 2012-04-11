require File.dirname(__FILE__) + '/../../test_helper'
require 'action_view/test_case'
# Make sure we have all news feed items in memory
Dir["#{RAILS_ROOT}/**/app/models/*_item.rb"].each do |path|
  require path
end
class NewsFeedHelperTest < ActionView::TestCase
  
  ActionController::Base.prepend_view_path "#{RAILS_ROOT}/client/app/views"

  NewsFeedHelper.send(:include, ::TextHelper)
  NewsFeedHelper.send(:include, ApplicationHelper)
  NewsFeedHelper.send(:include, MediaHelper)

  CUSTOM_TEST_FACTORIES = %w{}
  
  (NewsFeedItem.send(:subclasses) + CUSTOM_TEST_FACTORIES).each do |item|
    
    context "on call to render_item for #{item.to_s}" do
    
      setup do
        @response = ActionController::TestResponse.new
        @item = Factory.create(item.to_s.underscore.gsub(/\//, '_'))
        @response.body = render_item(@item)
      end
      
      should "render template" do
        assert_select "div.news_item"
      end
      
    end

    context "on call to render_item for merged #{item.to_s.pluralize}" do
    
      setup do
        @response = ActionController::TestResponse.new
        mergeable_item = Factory.create(item.to_s.underscore.gsub(/\//, '_'))
        @item = Factory.create(item.to_s.underscore.gsub(/\//, '_'))
        @item.merge!(mergeable_item)
        @response.body = render_item(@item)
      end
      
      should "render template" do
        assert_select "div"
      end
      
    end

    
  end
  
end
