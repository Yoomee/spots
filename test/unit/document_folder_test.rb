require File.dirname(__FILE__) + '/../test_helper'
class DocumentFolderTest < ActiveSupport::TestCase

  should have_many(:documents)

  should validate_presence_of(:name)
  
  context "a valid instance" do
    
    setup do
      @document_folder = Factory.build(:document_folder)
    end
    
    should "be_valid" do
      assert_valid @document_folder
    end
    
  end

end
