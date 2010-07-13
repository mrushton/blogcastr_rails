class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.integer :user_id, :null => false
      t.string :full_name
      t.string :motto
      t.string :location
      t.text :bio
      t.string :web
      t.string :time_zone
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.integer :theme_id, :null => false, :default => 1
      t.boolean :use_background_image, :null => false, :default => false
      t.string :background_image_file_name
      t.string :background_image_content_type
      t.integer :background_image_file_size
      t.datetime :background_image_updated_at
      t.boolean :tile_background_image
      t.boolean :scroll_background_image
      t.string :background_color, :limit => 7
      t.boolean :mobile_phone_confirmed
      t.boolean :mobile_phone_confirmation_sent
      t.string :mobile_phone_confirmation_token, :limit => 5
      t.string :mobile_phone_number, :limit => 10
      t.integer :mobile_phone_carrier_id
      t.boolean :post_blogcasts_to_facebook
      t.boolean :create_blogcast_facebook_events
      t.boolean :tweet_blogcasts
      t.boolean :send_message_email_notifications
      t.boolean :send_message_sms_notifications
      t.boolean :send_subscriber_email_notifications
      t.boolean :send_subscriber_sms_notifications
      t.boolean :send_subscription_blogcast_email_notifications
      t.boolean :send_subscription_blogcast_sms_notifications
      t.boolean :send_blogcast_email_reminders
      t.boolean :send_blogcast_sms_reminders
      #AS DESIGNED: this is only used for blogcast notifications
      t.string :email_reminder_units, :null => false, :default => "days"
      t.integer :email_reminder_time_before, :null => false, :default => 1
      t.string :sms_reminder_units, :null => false, :default => "hours"
      t.integer :sms_reminder_time_before, :null => false, :default => 1 
      t.timestamps
    end
  end

  def self.down
    drop_table :settings
  end
end
