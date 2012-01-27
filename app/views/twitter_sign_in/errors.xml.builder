xml.errors do
  @current_user.errors.full_messages.each { |message| xml.error(message) }
end
