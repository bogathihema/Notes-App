class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create, :welcome]
  def new
  end

  def logout
    session.clear
    redirect_to '/welcome'
  end

  def login

  end

  def welcome

  end

  def create
    @user = User.find_by(username: params[:username])
    if @user
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Notes Application."
      redirect_to user_notes_path(@user.id)
    else
      flash[:notice] = "User doesn't exist!"
      redirect_to "/welcome"
    end
  end
end
