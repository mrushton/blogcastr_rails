class SubscriptionMailer < ActionMailer::Base
  def email_notification(subscription)
    user = subscription.user
    subscribed_to = subscription.subscribed_to
    setting = user.setting
    from "notifications@blogcastr.com"
    recipients subscribed_to.email 
    subject "Subscription notification"
    body :user => user, :subscribed_to => subscribed_to
  end

  def sms_notification(subscription)
    user = subscription.user
    subscribed_to = subscription.subscribed_to
    setting = subscribed_to.setting
    mobile_phone_carrier = setting.mobile_phone_carrier 
    from "notifications@blogcastr.com"
    recipients setting.mobile_phone_number + "@" + mobile_phone_carrier.sms_email_host 
    subject "Subscription notification"
    body "Just a notification that #{user.username} is now subscribed to you."
  end
end
