class CreateUserNotifications < ActiveRecord::Migration
  def self.up
    create_table :user_notifications do |t|
      t.string :type, :null => false
      t.integer :user_id, :null => false
      t.integer :notifying_about, :null => false
      #AS DESIGNED - either 'email' or 'sms' makes certain queries easier
      t.string :delivered_by, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :user_notifications
  end
end
