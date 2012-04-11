require File.dirname(__FILE__) + '/../test_helper'
class PhotoAlbumTest < ActiveSupport::TestCase
  
  should have_many(:photos)
  
  context "a valid instance" do
    setup do 
      @photo_album = Factory.build(:photo_album)
    end
    
    should "be valid" do   
      assert @photo_album.valid?
    end    
  end
  
  context "when belongs to member and name is blank" do
    setup do
      @member = Factory.build(:member)
      @photo_album = Factory.build(:photo_album, :attachable => @member, :name => '')
    end
    
    should "name the album 'Untitled Album 1' if it is the member's first untitled album" do
      @photo_album.save
      assert_equal @photo_album.name, "Untitled Album 1"
    end
      
    should "name the album 'Untitled Album 2' if it is the member's second untitled album" do
      @member.photo_albums.expects(:untitled).returns [Factory.build(:photo_album)]
      @photo_album.save
      assert_equal @photo_album.name, "Untitled Album 2"
    end
  end
  
  context "when has no attachable and name is blank" do
    setup do
      @photo_album = Factory.build(:photo_album, :attachable => nil, :name => '')
    end
    
    should "name the album 'Untitled Album 1' if it is the first untitled album" do
      @photo_album.save
      assert_equal "Untitled Album 1", @photo_album.name
    end
      
    should "name the album 'Untitled Album 2' if it is the second untitled album" do
      PhotoAlbum.expects(:count).returns 1
      @photo_album.save
      assert_equal "Untitled Album 2", @photo_album.name
    end
  end  
end
