class UsersController < ApplicationController

  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = "Welcome aboard!"
      redirect_to @user
    else
      render :action => "new"
    end
  end

  def show
    @user = User.find_by_lastfm_username(params[:lastfm_username])
    raise ActiveRecord::RecordNotFound if @user.nil?

    @known_interests = @user.interests.known
  end
end
