require File.dirname(__FILE__) + '/../test_helper'
class PhotoAlbumsControllerTest < ActionController::TestCase
  
  should have_action(:create).with_level(:member_only)
  should have_action(:destroy).with_level(:owner_only)
  should have_action(:edit).with_level(:owner_only)
  should have_action(:index).with_level(:admin_only)
  should have_action(:new).with_level(:member_only)
  should have_action(:update).with_level(:owner_only)
  
  context "create action" do
    setup do
      stub_access
    end
    
    should "redirect when model is valid" do
      PhotoAlbum.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to photo_album_photos_url(assigns(:photo_album))
    end

    should "render new template when model is invalid" do
      PhotoAlbum.any_instance.stubs(:valid?).returns(false)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      post :create
      assert_template 'new'
    end
    
  end
  
  context "destroy action" do
    setup do
      stub_access
      @photo_album = Factory.create(:photo_album)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @photo_album
      assert_redirected_to photo_albums_url
      assert !PhotoAlbum.exists?(@photo_album.id)
    end
  end

  context "edit action" do
    setup do
      stub_access
      @photo_album = Factory.create(:photo_album)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render edit template" do
      get :edit, :id => @photo_album
      assert_template 'edit'
    end
  end
  
  context "index action" do
    should "render index template" do
      expect_admin
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :index
      assert_template 'index'
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
  
  context "update action when attributes are invalid" do
    
    setup do
      stub_access
      @photo_album = Factory.build(:photo_album, :id => 456)
      PhotoAlbum.stubs(:find).returns @photo_album
      @photo_album.stubs(:update_attributes).returns false
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    context 'POST' do
      
      setup do
        post :update, :id => 123, :photo_album => {:valid_attributes => false}
      end
      
      before_should "find the photo album" do
        PhotoAlbum.expects(:find).with('123').returns @photo_album
      end
      
      before_should "attempt to save the photo album" do
        @photo_album.expects(:update_attributes).with('valid_attributes' => false).returns false
      end
      
      should render_template(:edit)
      
    end
    
  end
  
  context "update action when attributes are valid" do
    
    setup do
      stub_access
      @photo_album = Factory.build(:photo_album, :id => 456)
      PhotoAlbum.stubs(:find).returns @photo_album
      @photo_album.stubs(:update_attributes).returns true
    end
    
    context 'POST' do
      
      setup do
        post :update, :id => 123, :photo_album => {:valid_attributes => true}
      end
  
      before_should "find the photo album" do
        PhotoAlbum.expects(:find).with('123').returns @photo_album
      end
      
      before_should "save the photo album" do
        @photo_album.expects(:update_attributes).with('valid_attributes' => true).returns true
      end
      
      should redirect_to("the photo album") {photo_album_photos_path(@photo_album)}
      
    end

  end
  
end
