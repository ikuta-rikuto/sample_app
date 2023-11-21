class NotificationsController < ApplicationController
  before_action :correct_user

  def index
    @user = User.find(params[:user_id])
    @grouped_notifications_messages = Notification.grouped_notifications(@user)
  end

  def mark_as_read
    @user = User.find(params[:user_id])
    grouped_notifications = Notification.grouped_notifications(@user)
    grouped_notifications.each do |message, notification, notification_time|
      if notification.id == params[:id].to_i
        notification_time.each do |notification|
          notification.each { |notification_read| notification_read.update(read: true) }
        end
      end
    end
    redirect_to user_notifications_path(user_id: @user.id), notice: '通知を既読にしました'
  end

  private

  def correct_user
    @user = User.find(params[:user_id])
    redirect_to(root_url, status: :see_other) unless @user == current_user
  end

end
