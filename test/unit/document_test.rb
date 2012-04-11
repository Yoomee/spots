require File.dirname(__FILE__) + '/../test_helper'
class DocumentTest < ActiveSupport::TestCase

  should belong_to(:member)
  should belong_to(:folder)
  
  context "a valid instance" do
    
    setup do
      @document = Factory.build(:document)
    end
    
    should "be_valid" do
      assert_valid @document
    end
    
  end

  context "on call to  named_scope without_folder" do
    
    setup do
      @document1 = Factory.create(:document, :folder => Factory.create(:document_folder))
      @document2 = Factory.create(:document, :folder => nil)
    end
    
    should "return only documents that are not in a folder" do
      assert_equal [@document2], Document.without_folder
    end
    
  end

end
