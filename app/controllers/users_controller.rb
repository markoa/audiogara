class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_lastfm_username(params[:user][:lastfm_username]) unless params[:user].nil?

    if @user.present?
      @user.build_profile
      redirect_to(:action => "show", :lastfm_username => @user.lastfm_username) and return
    end

    @user = User.new(params[:user])

    if @user.save
      @user.build_profile
      flash[:notice] = "Welcome aboard!"
      redirect_to(:action => "show", :lastfm_username => @user.lastfm_username)
    else
      render(:action => "new")
    end
  end

  def show
    @user = User.find_by_lastfm_username(params[:lastfm_username])
    raise ActiveRecord::RecordNotFound if @user.nil?

    @interesting_torrents = @user.interesting_torrents
  end
end
