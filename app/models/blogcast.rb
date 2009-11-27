class Blogcast < ActiveRecord::Base
  belongs_to :user
  has_many :posts
  has_many :comments
  has_many :likes
  has_many :views
  acts_as_solr :fields => [:title, :tags, :description, {:starting_at => :date}, {:user_id => :integer}]
end
