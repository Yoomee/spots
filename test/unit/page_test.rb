require File.dirname(__FILE__) + '/../test_helper'
class PageTest < ActiveSupport::TestCase

  include TextHelper
  
  should have_db_column(:expires_on).of_type(:datetime)
  should have_db_column(:text).of_type(:text)
  should have_db_column(:title).of_type(:string)
  should have_db_column(:small_title).of_type(:string)

  should belong_to(:photo)
  should belong_to(:section)

  should validate_presence_of(:expires_on)
  should validate_presence_of(:publish_on)
  should validate_presence_of(:text)
  should validate_presence_of(:title)
  should validate_presence_of(:section)
  
  should allow_value("<p>Some text</p>").for(:text)
  should allow_value("Some text").for(:text)
  should_not allow_value("").for(:text)
  should_not allow_value("<br />\r\n").for(:text)
  should_not allow_value("<p></p>").for(:text)
  
  context "a new instance" do
    
    setup do
      @page = Factory.build(:page)
    end
    
    should 'have a far-off time as its expires_on date' do
      assert @page.expires_on > 10.years.from_now
    end
    
    # For some reason, we get a wierd failure error ([no difference--suspect ==]) if we try and use an equality test
    
    should 'have a publish_on date greater than a minute ago' do
      assert 1.minute.ago < @page.publish_on
    end
    
    should 'have a publish_on date less than a minute from now' do
      assert 1.minute.from_now > @page.publish_on
    end
    
  end

  context "a new instance without permalink" do
    
    setup do
      @page1 = Factory.create(:page)
      @page2 = Factory.create(:page)
    end
    
    should 'create a unique default permalink when saved' do
      assert_equal @page1.permalink_name, "a-page"
      assert_equal @page2.permalink_name, "a-page-1"
    end
    
  end
  
  context "a child section page" do
    
    setup do
      @page = Factory.build(:page, :section => Factory.build(:child_section))
    end
   
    should "return the parent section, child section and the page for breadcrumb" do
      assert_equal [@page.section.parent, @page.section, @page], @page.breadcrumb
    end
     
  end
  
  context "a root section page" do
    
    setup do
      @page = Factory.build(:page, :section => Factory.build(:root_section))
    end
    
    should "return just the page's section and itself in an array for breadcrumb" do
      assert_equal [@page.section, @page], @page.breadcrumb
    end 
    
  end
  
  context "after updating permalink_name" do
    
    setup do
      @page = Factory.create(:page)
      @page.permalink_name = 'test-permalink'
      @page.save!
    end
    
    should "have set the permalink" do
      @page.reload
      assert_equal 'test-permalink', @page.permalink_name
    end
    
  end
  
  context "an instance" do
    
    setup do
      @page = Factory.build(:page)
    end
    
    should "return false to has_snippet?(:test)" do
      assert !@page.has_snippet?(:test)
    end

    should "return the permalink name on call to attributes" do
      assert_contains @page.attributes.keys, 'permalink_name'
    end
    
  end
  
  context "an instance after a pull quote text is set" do

    setup do
      @page = Factory.build(:page)
      @page.snippet_test = 'This is a test'
    end

    should "include the pull quote's text in its attributes" do
      assert_equal 'This is a test', @page.attributes['snippet_test']
    end

    should "return the pull quote text on call to it" do
      assert_equal 'This is a test', @page.snippet_test
    end
    
    should "return true to has_snippet?(:test)" do
      assert @page.has_snippet?(:test)
    end
    
  end
  
  context "an instance with a blank permalink_name" do
    
    setup do
      @page = Factory.build(:page, :permalink_name => '')
    end
    
    should "be valid" do
      assert @page.valid?
    end
    
  end

  context "an instance with a duplicate permalink_name" do
    
    setup do
      page = Factory.create(:page, :permalink_name => 'Test')
      @page = Factory.build(:page, :permalink_name => 'Test')
      @valid = @page.valid?
    end
    
    should "be invalid" do
      assert !@valid
    end
    
    should "have errors on permalink_name" do
      assert @page.errors.on(:permalink_name).size > 0
    end
      
  end
  
  context "an instance with a photo" do
    
    setup do
      @page = Factory.build(:page_with_photo)
    end
    
    should "return true to has_photo?" do
      assert @page.has_photo?
    end
    
  end
  
  context "an instance with just snippet_summary changed" do
    
    setup do
      @page = Factory.create(:page)
      @page.snippet_summary_text = 'changed'
    end
    
    should "return {'snippet_summary_text' => [nil, 'changed']} to changes" do
      assert_equal({'snippet_summary_text' => [nil, 'changed']}, @page.changes)
    end
    
    should "return ['snippet_summary_text'] to changed" do
      assert_equal ['snippet_summary_text'], @page.changed
    end
    
    should "return true to changed?" do
      assert @page.changed?
    end
    
    should "save the snippet_summary_text" do
      @page.save!
      @page.reload
      assert_equal 'changed', @page.snippet_summary_text
    end
    
    
  end
  
  context "an instance with snippet_summary_text not set" do
    
    setup do
      @page = Factory.build(:page)
    end
    
    should "return a truncation of the page text of the given length on call to summary with a length" do
      assert_equal @page.text.truncate_html(50), @page.summary(50)
    end
    
    should "return a truncation of the page text on call to summary" do
      assert_equal @page.text.truncate_html(Page::SUMMARY_LENGTH), @page.summary
    end
    
  end

  context "an instance with snippet_summary_text set" do
    
    setup do
      @page = Factory.build(:page, :snippet_summary_text => Lorem::Base.new('paragraphs', 2).output)
    end
    
    should "return a truncation of snippet_summary of the given length on call to summary with a length" do
      assert_equal @page.snippet_summary_text.truncate_html(50), @page.summary(50)
    end
    
    should "return a truncation of snippet_summary on call to summary" do
      assert_equal @page.snippet_summary_text.truncate_html(Page::SUMMARY_LENGTH), @page.summary
    end
    
  end
  
  context "an instance with text changed" do
    
    setup do
      @page = Factory.create(:page, :text => 'Old value')
      @page.text = 'New value'
    end
    
    should "return {'text' => ['Old value', 'New value'] to changes" do
      assert_equal({'text' => ['Old value', 'New value']}, @page.changes)
    end
    
    should "return ['text'] to changed" do
      assert_equal ['text'], @page.changed
    end
    
    should "return true to changed?" do
      assert @page.changed?
    end
  
  end
  
  context "an instance without a photo" do
    
    setup do
      @page = Factory.build(:page_without_photo)
    end
    
    should "return false to has_photo?" do
      assert !@page.has_photo?
    end
    
  end

  context "class on call to published" do
    
    should "not return a not-yet published page" do
      page = Factory.create(:page, :publish_on => 1.day.from_now, :expires_on => 2.days.from_now)
      assert_equal [], Page.published
    end
    
    should "not return an expired page" do
      page = Factory.create(:page, :publish_on => 2.days.ago, :expires_on => 1.day.ago)
      assert_equal [], Page.published
    end
    
    should "return a published page" do
      page = Factory.create(:page, :publish_on => 1.day.ago, :expires_on => 1.day.from_now)
      assert_equal [page], Page.published
    end
    
  end
  
  context "on call to been_published?" do
    
    should 'return false when the page is published in a minute' do
      @page = Factory.build(:page, :publish_on => 1.minute.from_now)
      assert !@page.been_published?
    end
    
    should 'return true when the page was published a minute ago' do
      @page = Factory.build(:page, :publish_on => 1.minute.ago)
      assert @page.been_published?
    end
    
    should 'return true when the page was published now' do
      @page = Factory.build(:page, :publish_on => Time.zone.now)
      assert @page.been_published?
    end
    
  end
  
  context "on call to expired?" do
    
    should 'return false when the page expires in a minute' do
      @page = Factory.build(:page, :expires_on => 1.minute.from_now)
      assert !@page.expired?
    end
  
    should 'return true when the page expired a minute ago' do
      @page = Factory.build(:page, :expires_on => 1.minute.ago)
      assert @page.expired?
    end
    
  end

  context "on call to published?" do
    
    should 'return false if expired' do
      @page = Factory.build(:page, :expires_on => 1.day.ago)
      assert !@page.published?
    end
    
    should 'return false if not yet published' do
      @page = Factory.build(:page, :publish_on => 1.day.from_now)
      assert !@page.published?
    end
    
    should 'return true by default' do
      @page = Factory.build(:page)
      assert @page.published?
    end
    
    should 'return true if published and not expired' do
      @page = Factory.build(:page, :publish_on => 1.day.ago, :publish_on => 1.day.from_now)
    end      
    
  end
  
  context "on call to breadcrumb" do
    setup do
      @root_section = Factory.build(:section)
      @section = Factory.build(:section, :parent => @root_section)
      @page = Factory.build(:page, :section => @section)
    end
    
    should 'return array of parents and self' do
      assert_equal @page.breadcrumb, [@root_section, @section, @page]
    end
  end

  context "on call to named_scope latest" do
    
    should "return pages ordered by weight and then publish_on DESC" do
      Factory.create(:page, :id => 5, :title => 'Page 5', :weight => 1)
      Factory.create(:page, :id => 2, :title => 'Page 2')
      Factory.create(:page, :id => 3, :title => 'Page 3', :publish_on => 1.day.ago)
      Factory.create(:page, :id => 4, :title => 'Page 4', :publish_on => 2.days.ago)
      Factory.create(:page, :id => 1, :title => 'Page 1', :weight => -1)
      assert_equal [1, 2, 3, 4, 5], Page.latest.collect(&:id)
    end
    
  end

  context "class call to slug" do
    
    should "return page if one exists with the slug" do
      page = Factory.create(:page, :slug_name => "existing_slug")
      assert_equal page, Page.slug(:existing_slug)
    end
    
    should "create new page if one doesn't exist with slug" do
      Factory.create(:section)
      page = Page.slug(:new_slug)
      assert_equal page, Permalink.find_by_slug('new_slug').model
    end
    
  end

  context "using formatted_time_accessor" do
    
    setup do
      @page = Factory.build(:page)
    end
    
    should "save time in correct format" do
      @page.formatted_publish_on = "18/12/2010 13:00"
      assert_equal Time.zone.parse("18-12-2010 13:00"), @page.publish_on
    end
    
    should "add error when time is incorrect format" do
      @page.formatted_publish_on = "incorrect_date/12/10"
      assert !@page.valid? && !@page.errors.on(:formatted_publish_on).blank?
    end
    
    should "do nothing if passed blank value" do
      @page.formatted_publish_on = ""
      assert_equal @page.publish_on, nil
    end
    
    should "still add error if passed blank value" do
      @page.publish_on = nil
      @page.formatted_publish_on = ""
      assert !@page.valid? && !@page.errors.on(:publish_on).blank?
    end
    
  end

end
