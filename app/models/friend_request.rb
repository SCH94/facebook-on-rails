class FriendRequest < ApplicationRecord
  
  after_create do
    friend.notify!(user, :friend_request, self)
  end
  
  belongs_to :user
  belongs_to :friend, class_name: "User"
                                  
  has_many :notifications_associated_with, class_name: "Notification",
                                           as: :notifiable,
                                           dependent: :destroy
  
  validates :user_id, uniqueness: { scope: :friend_id }
  validate :avoid_befriending_self
  validate :avoid_sending_if_already_friends
  
  def self.fetch(user1, user2)
    where(user: user1, friend: user2).first
  end
  
  private
  
    def avoid_befriending_self
      errors.add(:user_id, "cannot befriend itself.") if user_id == friend_id
    end

    def avoid_sending_if_already_friends
      if Friendship.exists?(user: user_id, friend: friend_id)
      	errors.add(:friend_id, "is already a friend.")
      end	
    end
end
