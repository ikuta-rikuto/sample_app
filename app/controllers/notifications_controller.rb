class NotificationsController < ApplicationController
  before_action :correct_user

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

    # 各グループに対してメッセージと通知オブジェクトを作成
    @grouped_notifications_messages = grouped_notifications.map do |group|
      message = if group.first.notification_type == 'follow'
        names = group.map { |n| n.relationship&.follower&.name }.compact
        if names.size > 1
          "#{names.first}さん他#{names.size - 1}名にフォローされました [#{group.first.created_at.in_time_zone('Tokyo').strftime('%Y/%m/%d %H:%M')}]"
        else
          "#{names.first}さんにフォローされました [#{group.first.created_at.in_time_zone('Tokyo').strftime('%Y/%m/%d %H:%M')}]"
        end
      elsif group.first.notification_type == 'first_login'
        group.first.message
      end

      [message, group.first]
    end.reject { |message, notification| notification.read }
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    if @notification.update(read: true)
      redirect_to user_notifications_path(user_id: @notification.user_id), notice: '通知を既読にしました'
    else
      redirect_to user_notifications_path(user_id: @notification.user_id), alert: '既読にすることができませんでした'
    end
  end

  private
  def correct_user
    @user = User.find(params[:user_id])
    redirect_to(root_url, status: :see_other) unless @user == current_user
  end

end
