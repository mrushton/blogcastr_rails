class Post < ActiveRecord::Base
  acts_as_tree
  belongs_to :blogcast
end
