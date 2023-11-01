class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :relationship, optional: true

  def create_follow_notification(user, relationship)
    self.user_id = user.id
    self.relationship_id = relationship.id
    self.notification_type = 'follow'
    follower_user = User.find(relationship.follower_id)
    self.message = "#{follower_user.name}さんにフォローされました"
    save!
  end

  # def mark_as_read
  #   puts "テスト"
  #   update(read: true)
  # end

end
