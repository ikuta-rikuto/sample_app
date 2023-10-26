class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    puts "テスト"
    @user = User.find(params[:followed_id])
    current_user.follow(@user)

    # 通知を作成する
    notification = Notification.new
    notification.create_follow_notification(@user, current_user)

    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
