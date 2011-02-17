require 'last_fm'

class UsersController < ApplicationController

  before_filter :find_user, :only => [:show, :signout, :ignore_artist, :hide_release, :owns_release]

  def new
    lastfm_username = get_name_from_cookie
    if lastfm_username.present?
      redirect_to(:action => "show", :id => lastfm_username) and return
    end

    @user = User.new
  end

  def create
    lastfm_username = params[:user].present? ? params[:user][:lastfm_username] : nil
    @user = User.find_by_lastfm_username(lastfm_username)

    if @user.present?
      @user.rebuild_profile
      self.current_user = @user
      redirect_to(@user) and return
    end

    lastfm_hash = LastFm::User.get_info(lastfm_username)

    if lastfm_hash.has_key?(:error)
      flash[:notice] = lastfm_hash[:error]
      render(:action => "new")
    else
      @user = User.new(params[:user])
      @user.update_profile_from_hash(lastfm_hash)
      @user.create_profile_job
      self.current_user = @user
      flash[:notice] = "Welcome aboard!"
      redirect_to(@user)
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if @user.nil?

    render(:action => "profile_pending") and return if @user.profile_pending?

    @interesting_torrents = @user.interesting_torrents
    if @interesting_torrents.count
      @known_interests_count = @user.interests.known.count
    end
  end

  def signout
    log_out(@user)
    redirect_to root_path
  end

  def ignore_artist
    artist = Artist.find(params[:artist_id])
    @user.ignore_artist(artist)
    head 200
  end

  def hide_release
    torrent = Torrent.find(params[:torrent_id])
    @user.hide_release_as_not_interesting(torrent)
    head 200
  end

  def owns_release
    torrent = Torrent.find(params[:torrent_id])
    @user.hide_release_as_owned(torrent)
    head 200
  end

  protected

  def find_user
    @user = User.find_by_lastfm_username(params[:id])
  end

end
