require File.dirname(__FILE__) + '/../test_helper'
class SearchControllerTest < ActionController::TestCase

  should route(:get, "/search/jquery_autocomplete.json").to(:controller => 'search', :action => 'jquery_autocomplete', :format => 'json')
  
  context "create action" do
    
    setup do
      @search = Search.new(:term => 'Test')
      Search.stubs(:new).returns @search
      @search.stubs(:results).with(nil).returns [Factory.build(:page)]
      @search.stubs(:results).with{|class_name, options| !class_name.nil?}.returns([])
      @search.stubs(:empty?).returns false
      @search.stubs(:size).returns 1
      might_expect_logged_in_member
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context "POST" do
      
      setup do
        post :create, :search => {:term => 'Test'}
      end
      
      before_should "build the search model" do
        Search.expects(:new).with {|attrs, options| attrs && attrs['term'] == 'Test'}.returns @search
      end
      
      should assign_to(:search).with {@search}
      
      should render_template(:create)
      
    end
       
  end
  
  context "jquery_autocomplete action" do
    
    setup do
      @search = Search.new(:term => 'Test')
      Search.stubs(:new).returns @search
      @search.stubs(:results).returns [Factory.build(:page)]
      might_expect_logged_in_member
    end
    
    context "GET" do
      
      setup do
        get :jquery_autocomplete, :q => 'Test', :format => 'json'
      end
      
      before_should "build the search model" do
        Search.expects(:new).with({:term => 'Test'}, :autocomplete => true).returns @search
      end
      
      should respond_with_content_type('application/json')
      
    end
    
  end
    
end