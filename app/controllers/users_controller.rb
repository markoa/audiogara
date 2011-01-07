class UsersController < ApplicationController

  include CookieHandler

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
      save_name_in_cookie(@user)
      redirect_to(@user) and return
    end

    @user = User.new(params[:user])

    if @user.save
      @user.build_profile
      save_name_in_cookie(@user)
      flash[:notice] = "Welcome aboard!"
      redirect_to(@user)
    else
      render(:action => "new")
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if @user.nil?
    @interesting_torrents = @user.interesting_torrents
  end

  def signout
    clear_name_from_cookie(@user)
    redirect_to root_path
  end

  protected

  def find_user
    @user = User.find_by_lastfm_username(params[:id])
  end

end
