class Blogcast < ActiveRecord::Base
  belongs_to :user
  has_many :posts
  has_many :comments
  has_many :subscriptions
end
