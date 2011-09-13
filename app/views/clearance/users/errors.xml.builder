xml.errors do
  @setting.errors.full_messages.each { |message| xml.error(message) }
  @blogcastr_user.errors.full_messages.each { |message| xml.error(message) }
end
