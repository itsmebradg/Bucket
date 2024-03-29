class UsersController < ApplicationController

	before_filter :authenticate, :only => [:index, :edit, :update]
	before_filter :correct_user, :only => [:edit, :update]
	before_filter :admin_user, :only => :destroy
	
  def index
  	@users = User.paginate(:page => params[:page])
  	@title = "Browse Users"
  end

  def show
    @user = User.find_by_id(params[:id])
	@microposts = @user.microposts
	@title = @user.name
  end
  
  def new
  	@user = User.new
    @title = "Register"
  end
  
  def create
  	@user = User.new(params[:user])
	if @user.save
		login @user
		flash[:success] = "Welcome to your bucket list!"
		redirect_to @user
	else
		@title = "Register"
  		render 'new'
	end
  end
  	
  def edit
  	@user = User.find(params[:id])
  	@title = "Edit Profile"
  end
  
  def update
  	@user = User.find(params[:id])
	if @user.update_attributes(params[:user])
		flash[:success] = "Your changes have been saved."
		redirect_to @user
	else
		@title = "Edit Profile"
  		render 'edit'
	end
  end
  
  def destroy
  	User.find(params[:id]).destroy
	redirect_to users_path, :flash => { :success  => "User has been deleted." }
  end
  
  private
	
	def correct_user
		@user = User.find(params[:id])
		redirect_to(root_path) unless current_user?(@user)
	end
	
	def admin_user
		user = User.find(params[:id])
		redirect_to(root_path) if !current_user.admin? || current_user?(user)
	end
	
end
