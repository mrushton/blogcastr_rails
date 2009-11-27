class Comment < ActiveRecord::Base
  belongs_to :blogcast
  belongs_to :user
  has_many :posts
  acts_as_solr
end
