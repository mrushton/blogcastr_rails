class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribed_to, :class_name => "User", :foreign_key => "subscribed_to"
  after_create :send_email_notification
  after_create :send_sms_notification

  private

  def send_email_notification
    if subscribed_to.setting.send_subscriber_email_notifications == true
      sent_subscription_notification = SentEmailSubscriptionNotification.find_by_user_id(user_id, :conditions => ["subscribed_to = ?", subscribed_to])
      if sent_subscription_notification.nil?    
        SubscriptionMailer.deliver_email_notification self
        SentEmailSubscriptionNotification.create(:user_id => user_id, :subscribed_to => subscribed_to, :delivered_by => "email")
      end
    end
  end

  def send_sms_notification
    if subscribed_to.setting.mobile_phone_confirmed == true && subscribed_to.setting.send_subscriber_sms_notifications == true
      sent_subscription_notification = SentSmsSubscriptionNotification.find_by_user_id(user_id, :conditions => ["subscribed_to = ?", subscribed_to])
      if sent_subscription_notification.nil?    
        SubscriptionMailer.deliver_sms_notification self
        SentSmsSubscriptionNotification.create(:user_id => user_id, :subscribed_to => subscribed_to, :delivered_by => "sms")
      end
    end
  end
end
