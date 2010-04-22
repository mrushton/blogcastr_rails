require 'net/http'

class Blogcast < ActiveRecord::Base
  validates_presence_of :title, :starting_at, :year, :month, :day, :link_title
  validate :unique_permalink?
  belongs_to :user
  has_many :posts
  has_many :comments
  has_many :likes
  has_many :views
  acts_as_solr :fields => [:title, :tags, :description, {:starting_at => :date}, {:user_id => :integer}]
  after_create :shorten_url

  #MVR - make sure permalink is not taken 
  def unique_permalink?
    if Blogcast.find(:first, :conditions => ["user_id = ? AND year = ? AND month = ? AND day = ? AND link_title = ?", user_id, year, month, day, link_title])
        errors.add(:link_title, "is already being used")
    end
  end

  def get_num_viewers
    num_viewers = CACHE.get("Blogcast:" + id.to_s + "-num_viewers") 
    unless num_viewers 
      num_viewers = thrift_client.get_num_muc_room_occupants("blogcast." + id.to_s)
      CACHE.set("Blogcast:" + id.to_s + "-num_viewers", num_viewers, 30.seconds)
    end
    num_viewers
  end

  #TODO: fix me!
  def thrift_client
    return @thrift_client if defined?(@thrift_client)
    @thrift_socket = Thrift::Socket.new("localhost", 9090)
    #TODO: investigate multiple transports 
    @thrift_transport = Thrift::BufferedTransport.new(@thrift_socket)
    @thrift_transport.open
    @thrift_protocol = Thrift::BinaryProtocol.new(@thrift_transport)
    @thrift_client = Thrift::Blogcastr::Client.new(@thrift_protocol)
  end

  def thrift_client_close
    @thrift_transport.close if defined?(@thrift_transport)
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
