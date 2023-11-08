class RemoveFollowerIdFromNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_column :notifications, :follower_id, :integer
  end
end
