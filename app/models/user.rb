class User < ActiveRecord::Base
  include Clearance::User
  has_one :blogcast
  has_one :setting
  has_many :posts
  has_many :comments
  has_many :subscriptions
  has_many :subscribed_blogcasts, :through => :subscriptions, :source => :blogcasts
end
