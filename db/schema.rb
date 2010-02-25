# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100218034011) do

  create_table "blogcast_notifications", :force => true do |t|
    t.string   "type",        :null => false
    t.integer  "user_id",     :null => false
    t.integer  "blogcast_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogcasts", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.string   "title",                      :null => false
    t.string   "tags"
    t.string   "description"
    t.integer  "year",                       :null => false
    t.integer  "day",                        :null => false
    t.integer  "month",                      :null => false
    t.string   "link_title",                 :null => false
    t.datetime "starting_at",                :null => false
    t.integer  "views_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "blogcast_id", :null => false
    t.string   "from",        :null => false
    t.string   "text",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "blogcast_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "type",               :null => false
    t.integer  "user_id",            :null => false
    t.integer  "blogcast_id",        :null => false
    t.string   "from",               :null => false
    t.string   "text"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "comment_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.integer  "user_id",                                                       :null => false
    t.string   "full_name"
    t.string   "motto"
    t.string   "location"
    t.string   "bio"
    t.string   "web"
    t.string   "time_zone"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "theme_id",                                   :default => 1,     :null => false
    t.boolean  "use_background_image",                       :default => false, :null => false
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.datetime "background_image_updated_at"
    t.boolean  "tile_background_image"
    t.boolean  "scroll_background_image"
    t.string   "background_color",              :limit => 7
    t.boolean  "mobile_confirmed"
    t.string   "mobile_confirmation_token",     :limit => 5
    t.string   "mobile_number"
    t.string   "carrier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "subscribed_to", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", :force => true do |t|
    t.string   "title"
    t.string   "background_image_file_name"
    t.string   "background_image_content_type"
    t.integer  "background_image_file_size"
    t.boolean  "tile_background_image"
    t.boolean  "scroll_background_image"
    t.string   "background_color"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_notifications", :force => true do |t|
    t.string   "type",            :null => false
    t.integer  "user_id",         :null => false
    t.integer  "notifying_about", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "type",                                                   :null => false
    t.string   "username",             :limit => 15
    t.string   "email"
    t.string   "encrypted_password",   :limit => 128
    t.string   "salt",                 :limit => 128
    t.string   "confirmation_token",   :limit => 128
    t.string   "remember_token",       :limit => 128
    t.string   "authentication_token", :limit => 128
    t.boolean  "email_confirmed",                     :default => false, :null => false
    t.integer  "facebook_id"
    t.integer  "twitter_id"
    t.string   "twitter_access_token"
    t.string   "twitter_token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "views", :force => true do |t|
    t.integer  "blogcast_id", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
