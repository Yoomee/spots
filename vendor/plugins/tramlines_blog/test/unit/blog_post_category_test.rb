require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class BlogPostCategoryTest < ActiveSupport::TestCase

  should belong_to(:member)
  should have_and_belong_to_many(:blog_posts)

end
