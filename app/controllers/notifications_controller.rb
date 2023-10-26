class NotificationsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @notifications = @user.notifications.where.not(follower_id: -1)
    # @notifications = @user.notifications.order(created_at: :desc)
  end
end
