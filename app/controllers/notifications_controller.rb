class NotificationsController < ApplicationController
  before_action :correct_user

  def index
    @user = User.find(params[:user_id])
    @grouped_notifications_messages = Notification.grouped_notifications(@user)
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
