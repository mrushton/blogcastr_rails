class Comment < ActiveRecord::Base
  belongs_to :blogcast
  belongs_to :user
  has_one :post
  acts_as_solr
end
