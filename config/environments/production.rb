# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

#MVR - mail relay
config.action_mailer.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => 25,
  :domain => "blogcastr.com",
  :authentication => :login,
  :user_name => "mrushton@blogcastr.com",
  :password => "hkbcfjiP7"
}
config.action_mailer.default_url_options = {:host => "blogcastr.com"}

# Enable threaded mode
# config.threadsafe!

#MVR - define the host we are running on 
HOST = "blogcastr.com"
#MVR - thrift
THRIFT_HOST = "ejabberd.blogcastr.com"
THRIFT_PORT = 9090 
#MVR - memcached 
MEMCACHED_HOST = "memcached.blogcastr.com"
MEMCACHED_PORT = 11211
#MVR - Facebook app id
FACEBOOK_APP_ID = "130902392002"
#MVR - Facebook app secret 
FACEBOOK_APP_SECRET = "f056ec28e6463fe24469abb0b0a56e0f"
