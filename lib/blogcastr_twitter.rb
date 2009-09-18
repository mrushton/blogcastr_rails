module Twitter::NoAuth
  class NoAuth
    include HTTParty
    format :plain

    def initialize(options={})
      self.class.base_uri "http#{'s' if options[:ssl]}://twitter.com"
    end
    
    def get(uri, headers={})
      self.class.get(uri, :headers => headers)
    end
    
    def post(uri, body={}, headers={})
      self.class.post(uri, :body => body, :headers => headers)
    end
  end
end
