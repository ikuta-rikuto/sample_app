class NotificationsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @notifications = @user.notifications.order(created_at: :desc)

    # フォローされた時間が5分以内の通知をグループ化
    grouped_notifications = []
    @notifications.each do |notification|
      if grouped_notifications.empty? || (grouped_notifications.last.first.created_at - notification.created_at) > 5.minutes || grouped_notifications.last.first.notification_type != notification.notification_type
        grouped_notifications << [notification]
      else
        grouped_notifications.last << notification
      end
    end


    # 各グループに対してメッセージを作成
    @grouped_notifications_messages = grouped_notifications.map do |group|
      if group.first.notification_type == 'follow'
        names = group.map { |n| n.relationship&.follower&.name }.compact
        if names.size > 1
          "#{names.first}さん他#{names.size - 1}名にフォローされました"
        else
          "#{names.first}さんにフォローされました"
        end
      elsif group.first.notification_type == 'first_login'
        group.first.message
      end
    end
  end

end
