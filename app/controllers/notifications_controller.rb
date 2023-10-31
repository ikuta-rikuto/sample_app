class NotificationsController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @notifications = @user.notifications.where.not(follower_id: -1).order(created_at: :desc)

    # フォローされた時間が5分以内の通知をグループ化
    grouped_notifications = []
    @notifications.each do |notification|
      if grouped_notifications.empty? || (grouped_notifications.last.first.created_at - notification.created_at) > 5.minutes
        grouped_notifications << [notification]
      else
        grouped_notifications.last << notification
      end
    end

    # 各グループに対してメッセージを作成
    @grouped_notifications_messages = grouped_notifications.map do |group|
      names = group.map { |n| n.follower.name }
      puts "テスト"
      puts names
      puts @user.name

      if names.size > 1
        "#{names.first}さん他#{names.size - 1}名にフォローされました"
      elsif names.exclude?(@user.name)
        "#{names.first}さんにフォローされました"
      end
    end

  end
end
