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
    @user = User.find(params[:id])
  end
end
