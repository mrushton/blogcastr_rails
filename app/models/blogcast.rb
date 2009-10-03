class Blogcast < ActiveRecord::Base
  belongs_to :user
  has_many :posts
  has_many :comments
  has_many :likes
  has_many :views
end
