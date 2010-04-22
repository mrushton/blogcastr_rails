require 'test_helper'

class MobilePhoneMailerTest < ActionMailer::TestCase
  test "confirm" do
    @expected.subject = 'MobilePhoneMailer#confirm'
    @expected.body    = read_fixture('confirm')
    @expected.date    = Time.now

    assert_equal @expected.encoded, MobilePhoneMailer.create_confirm(@expected.date).encoded
  end

end
