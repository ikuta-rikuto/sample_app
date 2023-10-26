class NotificationsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @notifications = @user.notifications.order(created_at: :desc)
  end
end
