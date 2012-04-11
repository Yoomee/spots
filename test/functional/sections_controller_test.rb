require File.dirname(__FILE__) + '/../test_helper'
class SectionsControllerTest < ActionController::TestCase

  should have_action(:create).with_level(:admin_only)
  should have_action(:destroy).with_level(:admin_only)
  should have_action(:edit).with_level(:admin_only)
  should have_action(:index).with_level(:default)
  should have_action(:new).with_level(:admin_only)
  should have_action(:show).with_level(:default)
  should have_action(:update).with_level(:admin_only)
  
  context "create action with invalid attributes" do
    
    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:new).returns @section
      @section.stubs(:save).returns false
      stub_finds(Section, Factory.build(:section, :id => 456))
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context "POST" do
      
      setup do
        post :create, :section => {:valid_attributes => false}
      end
      
      before_should "initialize a section with the attributes" do
        Section.expects(:new).with('valid_attributes' => false).returns @section
      end
      
      before_should "attempt to save the section" do
        @section.expects(:save).returns false
      end
      
      should assign_to(:section).with {@section}
      should render_template(:new)
      
    end

  end
  
  context "create action with valid attributes" do

    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:new).returns @section
      @section.stubs(:save).returns true
    end

    context "POST" do
    
      setup do
        post :create, :section => {:valid_attributes => true}
      end
      
      before_should "initialize a section with the attributes" do
        Section.expects(:new).with('valid_attributes' => true).returns @section
      end
      
      before_should "save the section" do
        @section.expects(:save).returns true
      end
      
      should respond_with(:redirect)
      
    end
  
  end
  
  context "destroy action" do
    
    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:find).returns @section
      @section.stubs(:destroy).returns true
    end
  
    context "DELETE" do
      
      setup do
        delete :destroy, :id => 123
      end
      
      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end
      
      before_should "delete the section" do
        @section.expects(:destroy).returns true
      end
      
      should redirect_to('the index') {sections_path}
      
    end
    
  end
  
  context "edit action" do
    
    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:find).returns @section
      Section.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:section, :id => 456)]
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context "GET" do
      
      setup do
        get :edit, :id => 123
      end
      
      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end
     
      should assign_to(:section).with {@section}
      should render_template(:edit)
      
    end
    
  end
  
  context "index action" do
    
    setup do
      stub_finds(Section)
      @sections = [Factory.build(:section, :id => 1), Factory.build(:section, :id => 2, :pages => [Factory.build(:page, :id => 1)])]
      @sections.each {|section| section.stubs(:all_children).returns []}
      Section.stubs(:root).returns @sections
      @sections.stubs(:not_hidden).returns @sections
      @sections.stubs(:not_draft).returns @sections      
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context 'GET' do
      
      setup do
        might_expect_logged_in_member        
        get :index
      end
      
      should render_template(:index)
      should assign_to(:sections).with {@sections}
      
    end

    context 'GET for admin member' do
      
      setup do
        expect_admin
        get :index
      end
      
      should render_template(:index)
      should assign_to(:sections).with {@sections}
      
    end
    
  end
  
  context "new action" do
    
    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:new).returns @section
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context "GET" do
      
      setup do
        get :new
      end
      
      before_should "initialize a section" do
        Section.expects(:new).returns @section
      end
      
      should assign_to(:section).with {@section}
      should render_template(:new)
      
    end
    
  end

  context "new action where section_id is set" do
    
    setup do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context "GET" do
      
      setup do
        get :new, :section_id => 123
      end

      should assign_to(:section).with_kind_of(Section)
      should render_template(:new)
      
      should "set the section's parent id" do
        assert_equal 123, assigns['section'].parent_id
      end
      
    end
    
  end

  context "show action when section view is first_page" do
    
    setup do
      @page = Factory.build(:page, :id => 456)
      @page.stubs(:new_record?).returns false
      @section = Factory.build(:section, :view => 'first_page', :pages => [@page])
      @section.stubs(:all_children).returns [@page]
      Section.stubs(:find).returns Factory.build(:section)
      Section.stubs(:find).with('123').returns @section
    end

    context 'GET' do
      
      setup do
        might_expect_logged_in_member
        get :show, :id => 123
      end

      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end

      should redirect_to('the page') {page_path(@page)}

    end
    
  end
  
  context "show action when section view is latest_stories" do
    
    setup do
      @section = Factory.build(:section, :view => 'latest_stories', :id => 123)
      Section.stubs(:find).returns Factory.build(:section)
      Section.stubs(:find).with('123').returns @section
      Section.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:section, :id => 456)]
      @pages = [Factory.create(:page)]
      @children = [Factory.create(:section)]
      page_class_mock = mock
      @section.stubs(:pages).returns page_class_mock      
      page_class_mock.stubs(:published).returns page_class_mock
      page_class_mock.stubs(:latest).returns @pages
      page_class_mock.stubs(:weighted).returns @pages
      page_class_mock.stubs(:empty?).returns false
      @section.stubs(:children).returns @children
      @children.stubs(:not_hidden).returns @children
      Section.any_instance.stubs(:all_children).returns []
      Section.any_instance.stubs(:all_descendants).returns []
      @pages_sections = @children + @pages
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    context 'GET' do
      
      setup do
        might_expect_logged_in_member
        get :show, :id => 123
      end
   
      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end
      
      before_should "find the latest pages" do
        @section.expects(:pages).returns mock(:published => mock(:latest => @pages))
      end
    
      should render_template(:latest_stories)
      should assign_to(:section).with {@section}
      
      should "assign @pages_sections" do
        # This may return the pages and sections in a different order
        assert_equal @pages_sections.map(&:to_s).sort, assigns['pages_sections'].map(&:to_s).sort
      end

    end
    
  end
  
  context "show action when section view is normal" do
    
    setup do
      @section = Factory.build(:section, :view => 'normal', :id => 123)
      Section.stubs(:find).returns @section
      Section.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:section, :id => 456)]
    end
    
    context 'GET' do
      
      setup do
        might_expect_logged_in_member
        stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
        get :show, :id => 123
      end
    
      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end
    
      should render_template(:show)
      should assign_to(:section).with {@section}

    end
    
  end

  context "update action with invalid attributes" do
    
    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:find).returns @section
      Section.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:section, :id => 456)]
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      @section.stubs(:update_attributes).returns false
    end
    
    context 'PUT' do
      
      setup do
        put :update, :id => 123, :section => {:valid_attributes => false}
      end
      
      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end
      
      before_should "attempt to save the section" do
        @section.expects(:update_attributes).with('valid_attributes' => false).returns false
      end
      
      should assign_to(:section).with {@section}
      should render_template(:edit)
      
    end
    
  end
  
  context "update action with valid attributes" do
    
    setup do
      stub_access
      @section = Factory.build(:section)
      Section.stubs(:find).returns @section
      @section.stubs(:update_attributes).returns true
    end
    
    context 'PUT' do
      
      setup do
        put :update, :id => 123, :section => {:valid_attributes => true}
      end
      
      before_should "find the section" do
        Section.expects(:find).with('123').returns @section
      end
      
      before_should "save the section" do
        @section.expects(:update_attributes).with('valid_attributes' => true).returns true
      end
      
      should respond_with(:redirect)
      
    end
    
  end
  
end
