class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]
  def new
    @user = User.new
  end

  def create
    @user = User.create(username: params[:user][:username], password_digest: params[:user][:password])
    if @user.errors.present?
      flash[:notice] = "Please Enter valid Email format!"
      redirect_to '/users/new'
    else
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Notes dashboard!"
      redirect_to user_notes_path(@user.id)
    end
  end

  def index
    @users = User.all
  end
end
