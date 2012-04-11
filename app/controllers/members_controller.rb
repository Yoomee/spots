class MembersController < ApplicationController

  before_filter :get_member, :only => %w{destroy edit update json show change_password update_password}
  before_filter :report_error_if_logged_in_using_login_hash, :only => %w{change_password update_password}
  skip_before_filter :force_password_change, :only => %w{autocomplete change_password update_password}
  
  admin_only :destroy, :index
  member_only :show, :autocomplete, :json
  owner_only :edit, :update
  custom_permission :new, :create do |url_options, member|
    member.nil? || member.is_admin?
  end
  custom_permission :change_password, :update_password do |url_options, member|
    if Member.authenticate_from_hash(url_options[:login_hash_id], url_options[:login_hash])
      true
    else
      member && (member.is_admin? || (member.id == url_options[:id].to_i))
    end
  end

  class << self
    
    def allowed_to?(url_options, member)
      # To avoid letting someone destroy themselves!
      super(url_options, member) && !(url_options[:action].to_sym == :destroy && associated_model_instance_id(url_options[:id]) == member.id)
    end
    
  end
    
  def autocomplete
    default_image_url = Member.default_image.process(:thumb, "25x25#").url
    members = Member.search(params[:term], :index => "autocomplete_member")
    if Module.value_to_boolean(params[:friends_only])
      friend_ids = logged_in_member.friend_ids
      members.reject! {|m| !friend_ids.include?(m.id)}
    end
    members.collect! do |m|
      image_url = m.image.process(:thumb, "25x25#").url if m.has_image?
      {:id => m.id.to_s, :name => m.full_name, :image => image_url}
    end
    render :json => members
  end
  
  def create
    @member = Member.new(params[:member])
    @member.generate_random_password(true) if logged_in_member_is_admin?
    if @member.save
      if logged_in_member_is_admin?
        flash[:notice] = "The account has been created."
        redirect_to_waypoint
      else
        flash[:notice] = "Your account has been created. Welcome to #{APP_CONFIG['site_name']}."
        session[:logged_in_member_id] = @member.id if @logged_in_member.nil?
        redirect_to @member
      end
    else
      render :action => logged_in_member_is_admin?  ? 'new_by_admin' : 'new'
    end
  end
  
  def destroy
    @member.destroy
    flash[:notice] = "Member succesfully deleted."
    redirect_to members_path
  end
  
  def edit
  end
  
  def index
    @members = Member.all
  end
  
  def json
    data = {:id => @member.id, :full_name => @member.full_name}
    data[:image_url] = @member.image.nil? ? nil : @member.image.process(:thumb, params[:geometry] || APP_CONFIG[:photo_resize_geometry]).url
    render :json => {:member => data}
  end
  
  def new
    @member = Member.new
    render :action => 'new_by_admin' if logged_in_member_is_admin?
  end
  
  def change_password
    
  end
  
  def update_password
    @member.update_attributes(params[:member])
    if @member.valid?
      flash[:notice] = "Password changed succesfully."
      if login_hash = LoginHash.find_by_id(params[:login_hash_id])
        login_hash.destroy
        session[:logged_in_member_id] ||= @member.id
      end
      redirect_to_waypoint
    else
      render :action => "change_password"
    end
  end
  
  def resend_password
  end
  
  def resend_password_to_member
    member = Member.find :first, :conditions => "email = '#{params[:email_address]}'"
    if member
      Notifier.deliver_password_reminder member
      flash[:notice] = "Password reset instructions have been sent to your email address (#{params[:email_address]})."
      redirect_to home_url
    else
      flash[:error] = "Sorry, a member was not found with that email address."
      redirect_to :action => 'resend_password'
    end
  end
  
  def show

  end
    
  def update
    @member.update_attributes(params[:member])
    respond_to do |format|
      format.html do
        if request.xhr?
          ajax_update_response(@member, params[:wants], params[:sf])
        elsif @member.valid?
          flash[:notice] = "Profile updated"
          redirect_to @member
        else
          render :action => "edit"
        end
      end
      format.js do
        ajax_update_response(@member, params[:wants], params[:sf])
      end
      format.text do
        ajax_update_response(@member, params[:wants], params[:sf])
      end
    end
  end

  private
  def ajax_update_response(member, wants, sf = false)
    if member.invalid?
      render(:text => 'Invalid')
    elsif wants
      render(:text => sf ? @template.simple_format(@member.send(wants)) : @member.send(wants))
    else
      render(:text => 'Success')
    end
  end
     
  def get_member
    @member = Member.find params[:id]
  end

  def report_error_if_logged_in_using_login_hash
    if params[:login_hash_id] && logged_in? && !logged_in_as?(@member)
      return report_error("You're already logged in as #{logged_in_member}. Logout and try the link again.")
    end
  end
  
end
