class MobilePhoneMailer < ActionMailer::Base
  def confirm(user)
    setting = user.setting
    from "confirmations@blogcastr.com"
    #TODO: move this query to the mobile_phone controller
    recipients setting.mobile_phone_number + "@" + setting.mobile_phone_carrier.sms_email_host
    subject "Confirm your mobile phone"
    body "Hi #{user.username}! Enter this token to confirm your mobile phone: #{setting.mobile_phone_confirmation_token}"
  end
end
