# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_blogcastr_session',
  :secret      => '64b6897d9c763ced80230a04663fe1944ce185d53a9acad818a03c9bf687cec4a15dd8ab2b961ddae9086b0d53b8e2715988e4992c5600adedacfaa57cd05148'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
