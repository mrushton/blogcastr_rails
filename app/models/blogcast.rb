class Blogcast < ActiveRecord::Base
  validates_presence_of :title, :starting_at, :year, :month, :day, :link_title
  validate :unique_permalink?
  belongs_to :user
  has_many :posts
  has_many :comments
  has_many :likes
  has_many :views
  acts_as_solr :fields => [:title, :tags, :description, {:starting_at => :date}, {:user_id => :integer}]

  #MVR - make sure permalink is not taken 
  def unique_permalink?
    if Blogcast.find(:first, :conditions => ["user_id = ? AND year = ? AND month = ? AND day = ? AND link_title = ?", user_id, year, month, day, link_title])
        errors.add(:link_title, "is already being used")
    end
  end

  def get_username
    username
  end

  def get_url
    #MVR - it looks like objects don't get helpers so can't use blogast_path
    "/" + username 
  end

  def get_avatar_url(size)
    setting.avatar.url(size)
  end
end
