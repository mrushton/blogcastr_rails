class CreateBlogcastReminders < ActiveRecord::Migration
  def self.up
    create_table :blogcast_reminders do |t|
      t.string :type, :null => false
      t.integer :user_id, :null => false
      t.integer :blogcast_id, :null => false
      #AS DESIGNED - either 'email' or 'sms', needed to make query for reminders 
      t.string :delivered_by, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :blogcast_reminders
  end
end
