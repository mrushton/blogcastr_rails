class CreateBlogcastNotifications < ActiveRecord::Migration
  def self.up
    create_table :blogcast_notifications do |t|
      t.string :type, :null => false
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :blogcast_notifications
  end
end
