class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :blogcast, :counter_cache => true
end
