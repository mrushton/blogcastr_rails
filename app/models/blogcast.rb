require 'net/http'

class Blogcast < ActiveRecord::Base
  validates_presence_of :title, :starting_at, :year, :month, :day, :link_title
  validate :unique_permalink?
  belongs_to :user
  has_many :posts
  has_many :comments
  has_many :likes
  has_many :views
  has_many :blogcast_tags
  has_many :tags, :through => :blogcast_tags
  acts_as_solr :fields => [{:title => {:boost => 3.0}}, :description, :starting_at, :created_at, :user_id], :include => [:tags => {:using => :name, :multivalued => true, :boost => 2.0}]
  after_create :shorten_url

  #MVR - make sure permalink is not taken 
  def unique_permalink?
    if Blogcast.find(:first, :conditions => ["user_id = ? AND year = ? AND month = ? AND day = ? AND link_title = ?", user_id, year, month, day, link_title])
      errors.add(:link_title, "is already being used")
    end
  end

  def shorten_url
    begin
      json = Net::HTTP.get(URI.parse("http://api.bit.ly/v3/shorten?login=" + BITLY_LOGIN + "&apiKey=" + BITLY_API_KEY + "&uri=" + "http://" + HOST + "/" + user.username + "/" + year.to_s + "/" + month.to_s + "/" + day.to_s + "/" + link_title))
      response = ActiveSupport::JSON::decode(json)
      if response["status_code"] == 200
        update_attribute :short_url, response["data"]["url"]
      end
    rescue
      return
    end
  end
end
