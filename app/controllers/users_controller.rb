#Sources:
#https://www.railstutorial.org/book, Hartl Michael, 2014
#https://github.com/mislav/will_paginate

class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
 
  #this function shows all activated users, in alphabetical order. Paginate has been set to 20 to allow 20 users per page
  def index
    @users = User.where(activated: true). paginate(page: params[:page], :per_page => 20).order('name')
		if params[:search]
						@users = @users.search(params[:search])
		else
					  @users = @users.order(:name)
						@users = @users.where(activated: true). paginate(page: params[:page], :per_page => 20).order('name')
		end
  end
  
  #this function shows a users profile; user has been found by id
  def show
    @user = User.find(params[:id])
	  # if ((!current_user.blocked_by.nil?) and (!current_user.user_blocked_by?(@user)))
	  # if ((current_user.blocked_by.nil?) or (!current_user.user_blocked_by?(@user)))
		# check to see if the current user is blocked by @user
	  # if (!current_user.user_blocked_by?(@user))
	  if (!current_user.user_blocked_by?(@user)) # or (current_user.user_has_blocked(@user)))
						@rating_items = current_user.rating_feed.paginate(page: params[:page])
						@all_latlng = Array.new
						@skate_spots = @user.skate_spots
						@skate_spots.each do |s| 
										@all_latlng << s.name
										@all_latlng << s.latitude
										@all_latlng << s.longitude
						end 
						@microposts = @user.microposts.paginate(page: params[:page])
						@ratings = @user.ratings
						@events = Event.all
						# @rating = @skate_spot.ratings.build
	  else
							redirect_to users_url
	  end
  end
  
  #this function creates a User object 
  def new
    @user = User.new
  end
  
  #fills in the necessary attributes in the User DB for that user
  #filters out any inappropriate usernames
  def create
    @user = User.new(user_params)
    # hate_filter = LanguageFilter::Filter.new matchlist: :hate, replacement: :garbled
    # prof_filter = LanguageFilter::Filter.new matchlist: :profanity, replacement: :garbled 
    # sex_filter = LanguageFilter::Filter.new matchlist: :sex, replacement: :garbled 
    # viol_filter = LanguageFilter::Filter.new matchlist: :violence, replacement: :garbled 
    # if hate_filter.match?(@user.name) or prof_filter.match?(@user.name) or sex_filter.match?(@user.name) or viol_filter.match?(@user.name)
      #  flash[:warning] = "Please pick a more appropriate user name."
      # render 'new'
    # elsif @user.save
    if @user.save
       @user.send_activation_email
       flash[:info] = "Please check your email to activate your account."
       redirect_to root_url
    else
       render 'new'
    end
  end
  
  #edit action 
  def edit
    @user = User.find(params[:id])
  end
  
  #updates users via update_attributes based on what is defined in user_params
  #renders a view to edit users
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  #destroys/deletes a specified user account
  def destroy
    User.find(params[:id]).destroy #method chaining combines find & destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

	def followers
    @user = User.find(params[:id])
    @users = @user.followers.where(activated: true). paginate(page: params[:page], :per_page => 20).order('name')
	end
  
	def following
    @user = User.find(params[:id])
    @users = @user.following.where(activated: true). paginate(page: params[:page], :per_page => 20).order('name')
	end

	def blocked
    @users = User.where(id: current_user.user_blocked.keys)
    @users = @users.where(activated: true). paginate(page: params[:page], :per_page => 20).order('name')
	end

	def block_user
    @other_user = User.find(params[:other_user])
		current_user.update_attribute(:user_blocked, current_user.user_blocked.merge!(@other_user.id => @other_user.id))
		@other_user.update_attribute(:blocked_by, @other_user.blocked_by.merge!(current_user.id => current_user.id))
		if current_user.following?(@other_user)
						current_user.unfollow(@other_user)
		end
    redirect_to users_url
    flash[:success] = "You have successfully blocked #{@other_user.name}"
	end

	def unblock_user
    @other_user = User.find(params[:other_user])
		current_user.user_blocked.delete(@other_user.id)
		@other_user.blocked_by.delete(current_user.id)
		current_user.update_attribute(:user_blocked, current_user.user_blocked)
		@other_user.update_attribute(:blocked_by, @other_user.blocked_by)
    redirect_to @other_user
    flash[:success] = "You have successfully unblocked #{@other_user.name}"
	end

  private
 
    #attributes for user for above actions
    def user_params 
      params.require(:user).permit(:name, :email, :password, :password_confirmation    )
    end

    #confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless @user == current_user
    end
  
    #confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

     # confirms a logged-in user
     def logged_in_user
       unless logged_in?
         store_location
         flash[:danger] = "Please log in."
         redirect_to login_url
       end 
     end 

end
