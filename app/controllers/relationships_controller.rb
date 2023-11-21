class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    puts "テスト"
    @user = User.find(params[:followed_id])
    current_user.follow(@user)

    # 通知を作成する
    relationship = current_user.active_relationships.find_by(followed_id: @user.id)
    Notification.create_follow_notification!(@user, relationship)

    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @user = @relationship.followed

    # アンフォロー通知を非表示にする
    Notification.hide_follow_notification!(@user, @relationship)

    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
