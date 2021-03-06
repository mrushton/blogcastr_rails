class Post < ActiveRecord::Base
  belongs_to :blogcast
  belongs_to :user
  acts_as_tree
  acts_as_solr :fields => [:text, :created_at, :user_id]
end
