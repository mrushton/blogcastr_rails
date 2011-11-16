class Bitly
  attr_accessor :login, :api_key
  attr_reader :short_url

  def initialize(login, api_key)
    @login = login
    @api_key = api_key
  end

  def shorten(url)
    #MVR - create bitly link
    json = Net::HTTP.get(URI.parse("http://api.bit.ly/v3/shorten?login=" + @login + "&apiKey=" + @api_key + "&uri=" + url))
    response = ActiveSupport::JSON::decode(json)
    if response["status_code"] == 200
      @short_url = response["data"]["url"]
    else
      raise BitlyError, "Bitly api returned status code #{response["status_code"]}"
    end
  end
end

class BitlyError < StandardError
end
