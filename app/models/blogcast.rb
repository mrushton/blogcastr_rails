require 'net/http'

class Blogcast < ActiveRecord::Base
  validates_presence_of :title, :starting_at, :year, :month, :day, :link_title
  validates_length_of :title, :maximum => 35
  validates_uniqueness_of :link_title, :scope => [ :user_id, :year, :month, :day ]
  validate :valid_link_title?
  belongs_to :user
  has_many :posts, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :likes, :dependent => :delete_all
  has_many :views, :dependent => :delete_all 
  has_many :blogcast_tags, :dependent => :delete_all
  #MVR - do not destroy tags
  has_many :tags, :through => :blogcast_tags
  acts_as_solr :fields => [ { :title => { :boost => 3.0 } }, :description, :starting_at, :created_at, :user_id ], :include => [ :tags => { :using => :name, :multivalued => true, :boost => 2.0 } ]

  #MVR - make sure the link title is valid
  def valid_link_title?
    #MVR - periods are valid url characters but break rails routing
    if (link_title =~ /[^-A-Za-z0-9\$_\+!\*'\(\),]/)
      errors.add(:link_title, "is not valid")
    end
  end
end
