class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :relationship, optional: true

  # 1時間あたりの秒数
  SECONDS_IN_HOUR = 3600

  # 通知の種類
  NOTIFICATION_TYPES = {
    follow: ['follow'],
    first_login: ['first_login']
  }

  def self.create_follow_notification!(user, relationship)
    notification = self.new
    notification.user_id = user.id
    notification.relationship_id = relationship.id
    notification.notification_type = 'follow'
    follower_user = relationship.follower
    notification.message = "#{follower_user.name}さんにフォローされました"
    notification.save!
  end

  def self.grouped_notifications(user)
    # 未読の通知のみ取得
    notifications = user.notifications.where(read: false).order(created_at: :desc)

    grouped_notifications = divide_group_notifications_type(notifications)

    grouped_notifications.sort_by { |message, notification| -notification.created_at.to_i }
  end

  # 通知タイプごとに分けてそれぞれのメソッドを実行
  def self.divide_group_notifications_type(notifications)
    grouped_notifications = []
    NOTIFICATION_TYPES.each do |type, values|
      type_notifications = notifications.select { |n| values.include?(n.notification_type) }
      # 各通知メソッドを実行
      grouped_notifications += send("group_#{type}_notifications", type_notifications)
    end
    grouped_notifications
  end

  def self.group_first_login_notifications(first_login_notifications)
    first_login_notifications.map { |n| [n.message, n] }
  end

  def self.group_follow_notifications(follow_notifications)
    grouped_notifications_time = divide_group_notifications_time(follow_notifications)
    generate_group_message(grouped_notifications_time)
  end

  # 各タイプの通知を1時間ごとにグループ化する
  def self.divide_group_notifications_time(notification_each_type)
    grouped_notifications_time = []
    notification_each_type.each do |notification|
      if grouped_notifications_time.empty? || (grouped_notifications_time.last.first.created_at - notification.created_at) > SECONDS_IN_HOUR
        grouped_notifications_time << [notification]
      else
        grouped_notifications_time.last << notification
      end
    end
    grouped_notifications_time
  end

  # 通知の数と時間によって通知メッセージを変更
  def self.generate_group_message(grouped_notifications_time)
    grouped_notifications_time.map do |group|
      follower_name = User.find(group.first.relationship.follower_id).name

      # 何時間前にフォローされたか調べる
      hours_ago = ((Time.now - group.first.created_at) / SECONDS_IN_HOUR).round
      time = case hours_ago
      when 0
        ""
      when 1..24
        "#{hours_ago}時間前に"
      else
        "#{hours_ago / 24}日前に"
      end

      followers = group.size > 1 ? "#{follower_name}さん他#{group.size - 1}名" : "#{follower_name}さん"
      group_message = "#{time}#{followers}にフォローされました"

      group.each { |notification| notification.message = group_message }
      group.first.message = group_message
      [group.first.message, group.first]
    end
  end
end
