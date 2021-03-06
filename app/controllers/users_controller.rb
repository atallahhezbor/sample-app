class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy, :following, :followers] #moved to application controller
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
   
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url unless @user.activated?
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # log_in(@user)
      # flash[:success] = "Welcome to the Sample App!"
      # redirect_to @user
      UserMailer.account_activation(@user).deliver_now
      flash[:success] = "Please activate your account via the email we sent"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    #@user = User.find(params[:id]) #taken care of in the correct_user before action
  end

  def update
    #@user = User.find(params[:id]) #taken care of in the correct_user before action
    if @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted!"
    redirect_to users_url
  end

  def followers
    @title = "Followers"
    @user = User.find_by(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def following
    @title = "Following"
    @user = User.find_by(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  private
    #makes strong parameters
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url unless current_user?(@user)
    end

    def admin_user
      redirect_to root_url unless current_user.admin?
    end

end
