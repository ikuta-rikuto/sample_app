class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :follower, class_name: 'User', foreign_key: 'follower_id', optional: true

  def create_follow_notification(user, follower)
    self.user_id = user.id
    self.follower_id = follower.id
    self.notification_type = 'follow'
    self.message = "#{follower.name}さんにフォローされました"
    save!
  end

end
