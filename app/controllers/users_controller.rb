class UsersController < ApplicationController

  before_filter :find_user, :only => [:show, :signout]

  def new
    lastfm_username = get_name_from_cookie
    if lastfm_username.present?
      redirect_to(:action => "show", :id => lastfm_username) and return
    end

    @user = User.new
  end

  def create
    @user = User.find_by_lastfm_username(params[:user][:lastfm_username]) unless params[:user].nil?

    if @user.present?
      @user.rebuild_profile
      self.current_user = @user
      redirect_to(@user) and return
    end

    @user = User.new(params[:user])

    if @user.save
      @user.create_profile_job
      self.current_user = @user
      flash[:notice] = "Welcome aboard!"
      redirect_to(@user)
    else
      render(:action => "new")
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if @user.nil?

    if @user.profile_pending?
      render :action => "profile_pending"
    else
      @interesting_torrents = @user.interesting_torrents
    end
  end

  def signout
    log_out(@user)
    redirect_to root_path
  end

  protected

  def find_user
    @user = User.find_by_lastfm_username(params[:id])
  end

end
