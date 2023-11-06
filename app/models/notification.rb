class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :relationship, optional: true

  # 1時間あたりの秒数
  SECONDS_IN_HOUR = 3600

  def create_follow_notification(user, relationship)
    self.user_id = user.id
    self.relationship_id = relationship.id
    self.notification_type = 'follow'
    follower_user = User.find(relationship.follower_id)
    self.message = "#{follower_user.name}さんにフォローされました"
    save!
  end

  def self.grouped_notifications(user)
    notifications = user.notifications.order(created_at: :desc)

    grouped_notifications = []
    notifications.each do |notification|
      # ①grouped_notificationsが空であるか、②新しい通知と最後のグループ内の最初の通知との時間差が2時間以上であるかどうか、③新しい通知の種類が最後のグループ内の最初の通知種類と違うかをチェックする
      # 1つでも条件に当てはまれば、新しい通知グループを作成し通知を格納する。当てはまらない場合は既存の同じグループの配列の最後に値を格納する
      if grouped_notifications.empty? || (grouped_notifications.last.first.created_at - notification.created_at) > 1.hours || grouped_notifications.last.first.notification_type != notification.notification_type
        # 1件目の通知をgrouped_notificationsに挿入
        grouped_notifications << [notification]
      else
        # 2件目以降の通知をgrouped_notificationsに挿入
        grouped_notifications.last << notification
      end
      puts grouped_notifications
      puts grouped_notifications.size
    end

    grouped_notifications_messages = grouped_notifications.map do |group|
      message = if group.first.notification_type == 'follow'
        # フォロー解除された時に、nilになりフォロワーの名前が表示されないため、.compactを使用
        names = group.map { |n| n.relationship&.follower&.name }.compact
        # 現在の時間から最初の通知を引いた時間を計算
        hours_ago = ((Time.now - group.first.created_at) / SECONDS_IN_HOUR).round
        puts hours_ago
        if names.size > 1
          if hours_ago < 1
            "#{names.first}さん他#{names.size - 1}名にフォローされました"
          elsif hours_ago > 24
            "#{hours_ago / 24 }日前に#{names.first}さん他#{names.size - 1}名にフォローされました"
          else
            "#{hours_ago}時間前に#{names.first}さん他#{names.size - 1}名にフォローされました"
          end
        else
          if hours_ago < 1
            "#{names.first}さんにフォローされました"
          elsif hours_ago > 24
            "#{hours_ago / 24 }日前に#{names.first}さんにフォローされました"
          else
            "#{hours_ago}時間前に#{names.first}さんにフォローされました"
          end
        end
      elsif group.first.notification_type == 'first_login'
        group.first.message
      end

      puts "テスト"
      puts [message, group.first]
      [message, group.first]
      # 未読の通知のみを残す
      end.reject { |message, notification| notification.read }

    puts "テスト1"
    puts grouped_notifications_messages
    grouped_notifications_messages
  end

end
