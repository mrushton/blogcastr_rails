#MVR - seed data for the database
#MVR - users
#TODO: just use SQL for "Blogcastr User"
BlogcastrUser.create(:username => "BlogcastrUser", :email => "user@blogcastr.com", :email_confirmed => "false", :password => "password", :created_at => Time.now, :updated_at => Time.now)
BlogcastrUser.create(:username => "mrushton", :email => "mrushton7@yahoo.com", :password => "hkbcfjiP7", :email_confirmed => true, :created_at => Time.now, :updated_at => Time.now)
BlogcastrUser.create(:username => "krushtown", :email => "kyle.rushton@gmail.com", :password => "krushton", :email_confirmed => true, :created_at => Time.now, :updated_at => Time.now)
#MVR - settings
Setting.create(:user_id => 2, :full_name => "Matt Rushton", :location => "Cambridge, MA", :bio => "28 year old Software Engineer/Entrepreneur. I like Linux, the iPhone and biking.", :web => "http://flavors.me/mrushton", :time_zone => "Eastern Time (US & Canada)", :created_at => Time.now, :updated_at => Time.now)
Setting.create(:user_id => 3, :full_name => "Kyle Rushton", :motto => "Live blog or die", :location => "Boston, MA", :bio => "25-year-old entrepreneur... I enjoy biking, soccer, travel, and electronic/ house/ dance music", :web => "http://flavors.me/krushtown", :time_zone => "Eastern Time (US & Canada)", :avatar_file_name => "polaroid.jpg", :avatar_content_type => "image/jpeg", :avatar_file_size => 4705, :avatar_updated_at => Time.now, :background_image_file_name => "IMG_233___3.jpg", :background_image_content_type => "image/jpeg", :background_image_file_size => 281151, :background_image_updated_at => Time.now, :tile_background_image => false, :scroll_background_image => true, :created_at => Time.now, :updated_at => Time.now)
#MVR - themes
Theme.create(:title => "Default", :background_image_file_name => "default.png", :background_image_content_type => "image/png", :tile_background_image => false, :scroll_background_image => true, :background_color => "#e5e5e5")
