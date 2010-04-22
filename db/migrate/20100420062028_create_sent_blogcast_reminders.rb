class CreateSentBlogcastReminders < ActiveRecord::Migration
  def self.up
    create_table :sent_blogcast_reminders do |t|
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      #MVR - either 'email' or 'sms'
      t.string :delivered_by, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :sent_blogcast_reminders
  end
end
