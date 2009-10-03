class Comment < ActiveRecord::Base
  belongs_to :blogcast
  belongs_to :user
  has_many :posts
end
