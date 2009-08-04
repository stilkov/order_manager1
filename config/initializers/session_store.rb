# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :session_key => '_order_manager_session',
  :secret      => '734c85e9cbcfadebe3187175d9e36e2700c77544071a4a64e33e43cc0995c640657afd2bf022bb02d82aeaeb896ed2a7785749c60b4260cbee2e7b58c904d4cc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
