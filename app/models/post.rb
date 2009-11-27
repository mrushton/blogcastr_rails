class Post < ActiveRecord::Base
  belongs_to :blogcast
  acts_as_tree
  acts_as_solr
end
