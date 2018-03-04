class UsersController < ApplicationController
  
  before_action :load_user, only: [:show, :friends]
  before_action :load_friendship, only: :show
  
  def show
    @post = Post.new
  end
  
  def search
    @results = User.search(params[:q])
  end
  
  def friends
    @friends = @user.friends
  end
  
  private
  
    def load_user
      @user = User.find_by_username(params[:username])
    end
    
    def load_friendship
      @friendship = Friendship.between(current_user, @user) if user_signed_in? && current_user.friends_with?(@user)
    end
end