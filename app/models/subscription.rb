class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscribed_to, :class_name => "User", :foreign_key => "subscribed_to"
end
