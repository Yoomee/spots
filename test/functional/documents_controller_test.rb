require File.dirname(__FILE__) + '/../test_helper'
class DocumentsControllerTest < ActionController::TestCase
  
  should have_action(:create).with_default_level(:member_only)
  should have_action(:destroy).with_level(:owner_only)
  should have_action(:edit).with_level(:owner_only)
  should have_action(:index).with_default_level(:member_only)
  should have_action(:new).with_default_level(:member_only)
  should have_action(:update).with_level(:owner_only)
  
  context "create action" do

    setup do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render new template when model is invalid" do
      Document.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
  end
  
  context "destroy action" do

    setup do
      stub_access
      @document = Factory.create(:document)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @document
      assert_redirected_to documents_url
      assert !Document.exists?(@document.id)
    end

  end

  context "edit action" do

    setup do
      stub_access
      @document = Factory.create(:document)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render edit template" do
      get :edit, :id => @document
      assert_template 'edit'
    end

  end
  
  
  context "new action" do

    should "render new template" do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :new
      assert_template 'new'
    end

  end
  
  context "new action where document_folder_id is set" do

    setup do
      @document_folder = Factory.build(:document_folder, :id => 123)
      DocumentFolder.stubs(:find).returns @document_folder
      DocumentFolder.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:document_folder)]
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      stub_access
    end

    context "GET" do

      setup do
        get :new, :document_folder_id => 123
      end

      should assign_to(:document_folder).with_kind_of(DocumentFolder)
      should render_template(:new)

      should "set the folder_id for the document" do
        assert_equal @document_folder, assigns['document'].folder
      end

    end

  end
  
  context "show action" do

    setup do
      @document = Factory.create(:document)
      might_expect_logged_in_member
    end
    
  end
  
  context "update action" do

    setup do
      stub_access      
      @document = Factory.create(:document)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render edit template when model is invalid" do
      Document.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @document
      assert_template 'edit'
    end
  
  end
  
end
