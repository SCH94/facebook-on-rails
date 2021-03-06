class PostsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :load_user, only: :create
  before_action :redirect_if_not_friend_or_owner, only: :create
  before_action :load_post, only: [:show, :edit, :update, :destroy]
  before_action :admin_author_or_page_owner_only, only: :destroy
  before_action :author_only, only: [:edit, :update]
  before_action :check_if_owner_or_still_friends, only: [:edit, :update]
  
  def show
  end
  
  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end
    
  def create
    @post = @user.posts.build(post_params)
    @post.poster = current_user
    if @post.save
      flash[:success] = "Post created."
    else
      flash[:danger] = "Post creation failed."
    end
    redirect_to user_path(@user)
  end
  
  def update
    if @post.update_attributes(body: params[:post][:body])
      respond_to do |format|
        format.html { 
          flash[:success] = "Post updated."
          redirect_to @post
        }
        format.js
      end
    else
      respond_to do |format|
        format.html { 
          flash[:danger] = "Post not updated."
          redirect_to @post
        }
        format.js
      end
    end
   
  end
  
  def destroy
    @post.destroy
    flash[:notice] = "The post has been deleted."
    redirect_to user_path(@post.user)
  end
  
  private
    
    def post_params
      params.require(:post).permit(:body, :photo)
    end
    
    def load_user
      @user = User.find_by_username(params[:user_username])
    end
    
    def redirect_if_not_friend_or_owner
      unless current_user == @user || Friendship.exists?(user: current_user, friend: @user)
        flash[:danger] = "Sorry, you cannot post if are not friends."
        redirect_to @user
      end
    end
    
    def load_post
      @post = Post.find(params[:id])
    end
    
    def admin_author_or_page_owner_only
      redirect_to_post unless current_user == @post.poster || current_user == @post.user || current_user.admin?
    end
    
    def author_only
      redirect_to_post unless current_user == @post.poster
    end
    
    def check_if_owner_or_still_friends
      unless current_user == @post.user || Friendship.exists?(user: current_user, friend: @post.user)
        redirect_to_post
      end
    end
    
    def redirect_to_post
      flash[:danger] = "You are not authorized to do that."
      redirect_to @post
    end
end
