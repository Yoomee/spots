require File.dirname(__FILE__) + '/../test_helper'
class MemberTest < ActiveSupport::TestCase

  should have_db_column(:bio)
  should have_db_column(:created_at)
  should have_db_column(:email)
  should have_db_column(:forename)
  should have_db_column(:id)
  should have_db_column(:image_uid)
  should have_db_column(:password)
  should have_db_column(:surname)
  should have_db_column(:updated_at)
  should have_db_column(:username)

  should validate_presence_of(:forename)
  should validate_presence_of(:surname)

  should have_many(:login_hashes)

  should allow_value("anne.wareing@stgeorges.nhs.uk").for(:email)
  should_not allow_value("anne.wareing@stgeorges@nhs.uk").for(:email)
  
  # this fails because a random password is generated before_validation_on_create
  # should validate_presence_of(:password)

  context "a valid instance" do
    
    setup do
      @member = Factory.build(:member)
    end
    
    should "be_valid" do
      assert_valid @member
    end
    
  end
  
  context "validating email" do
    
    setup do
      @member = Factory.build(:member, :username => "username")
    end
    
    should "be valid if not blank" do
      assert @member.valid?
    end
    
    context "when allow_username_instead_of_email is false, email" do
      setup do
        @member.stubs(:allow_username_instead_of_email?).returns false
        @member.email = ""
      end
      
      should "be invalid if blank with username set" do
        assert !@member.valid?
      end
      
      should "be invalid if blank with username blank" do
        @member.username = ""
        assert !@member.valid?
      end
    end
    
    context "when allow_username_instead_of_email is true, email" do
      setup do
        @member.stubs(:allow_username_instead_of_email?).returns true
        @member.email = ""
      end
      
      should "be valid when blank with username set" do
        assert @member.valid?
      end
      
      should "be invalid when blank with username blank" do
        @member.username = ""
        assert !@member.valid?
      end
    end

  end
  
  context "class" do
    
    should "have image_accessor method" do
      assert_respond_to Member, :image_accessor
    end
    
  end

  context "class on call to authenticate with invalid email/username details" do
      
    should "return nil if email_or_username is blank" do
      assert_nil Member.authenticate('', 'pa55w0rd')
    end
      
    should "return nil if email_or_username is not found" do
      Member.expects(:find_by_email_or_username).with('bad').at_least_once.returns nil
      assert_nil Member.authenticate('bad', 'pa55w0rd')
    end

  end
    
  context "class on call to authenticate with valid details" do
      
    setup do
      @member = Factory.create(:member, :password => 'pa55w0rd')
      Member.expects(:find_by_email_or_username).with('good').returns @member
      @result = Member.authenticate('good', 'pa55w0rd')
    end
      
    should "return the member" do
      assert_equal @member, @result
    end
      
  end
    
  context "class on call to authenticate with valid email/username but invalid password" do

    setup do
      @member = Factory.create(:member, :password => 'pa55w0rd')
      Member.expects(:find_by_email_or_username).with('good').at_least_once.returns @member
      @result = Member.authenticate('good', 'password')
    end
      
    should "return nil" do
      assert_nil @result
    end

  end

  context "class on call to find_by_email_or_username do" do
    
    should "find a member if the email or username exists" do
      member = Factory.build(:member)
      Member.expects(:find).with(:first, :conditions => ["email=? OR username=?", 'good', 'good']).returns member
      assert_equal member, Member.find_by_email_or_username('good')
    end
      
    should "not find a member if the email or username doesn't exist" do
      Member.expects(:find).with(:first, :conditions => ["email=? OR username=?", 'good', 'good']).returns nil
      assert_nil Member.find_by_email_or_username('good')
    end
      
  end
  
  context "on call to has_image?" do
    
    should "return false when image_uid is blank" do      
      @member = Factory.build(:member, :image_uid => '')
      assert !@member.has_image?
    end
    
    should "return true when image_uid is not blank" do
      @member = Factory.build(:member, :image_uid => 'my_profile_image')
      assert @member.has_image?
    end
    
  end
  
  context "on call to image_uid" do
    
    should "return database value if one exists" do
      @member = Factory.build(:member, :image_uid => 'my_profile_image')
      assert_equal @member.image_uid, 'my_profile_image'
    end
    
  end

  context "on call to yoomee_staff?" do
    
    setup do
      @member = Factory.build(:member)
    end
    
    Member::YOOMEE_EMAILS.each do |yoomee_email|
      should "return true if member is #{yoomee_email}" do
        @member.email = yoomee_email
        assert @member.yoomee_staff?
      end
    end
    
    should "return false if member has not got correct email" do
      @member.email = "not_yoomee@yoomee.com"
      assert !@member.yoomee_staff?
    end
    
  end

  context "class on call to authenticate_with_hash" do
      
    setup do
      @member = Factory.create(:member)
      @login_hash = Factory.create(:login_hash, :member => @member, :id => 1)
    end
      
    should "return the member if valid hash" do
      assert_equal @member, Member.authenticate_from_hash(1, @login_hash.hash)
    end
    
    should "return false if invalid hash" do
      assert !Member.authenticate_from_hash(1, "wrong_hash")
    end
      
  end

  context "on call to validate_format_is_email_address_of" do

    setup do
      @member = Factory.build(:member, :email => nil)
    end
    
    should "not add errors if email address is blank" do
      @member.validate_format_is_email_address_of(%w{email})
      assert @member.errors[:email].blank?
    end
    
    should "add errors if email address is invalid" do
      @member.email = "invalidemail"      
      @member.validate_format_is_email_address_of(%w{email})
      assert !@member.errors[:email].blank?      
    end
    
    should "not add errors if email address is valid" do
      @member.email = "email@email.com"
      @member.validate_format_is_email_address_of(%w{email})
      assert @member.errors[:email].blank?
    end
    
  end

end

