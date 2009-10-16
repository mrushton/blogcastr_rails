# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#MVR - needed for clearence
DO_NOT_REPLY = "accounts@blogcastr.com"

#TODO: refactor this
#MVR - set up a Memcached client
require 'memcache'
CACHE = MemCache.new("localhost:11211")

#TODO - move token and secret to a config file
TWITTER_CONSUMER_KEY = "RyfjiSOXSXxyHkZjv4TsZA"
TWITTER_CONSUMER_SECRET = "jvTlEHNiyBa3gvWMoIgSWGtpvFY9A0x7G3NeeH5w"

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
  config.gem "thoughtbot-clearance", :lib => "clearance", :source => "http://gems.github.com", :version => "0.8.2"
  config.gem "thoughtbot-paperclip", :lib => "paperclip", :source => "http://gems.github.com"
  config.gem "aws-s3", :lib => "aws/s3"
  config.gem "thrift"
  config.gem "twitter"
  config.gem "memcache-client"
  config.gem "sqlite3-ruby"
  config.gem "postgres"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
