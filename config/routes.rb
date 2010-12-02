ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.

  #MVR - include all Clearance routes first since the Clearance engine avoids doing so with a hack
  map.resources :passwords, :controller => "clearance/passwords", :only => [:new, :create]
  map.resource :session, :controller => "clearance/sessions", :only => [:new, :create, :destroy]
  map.resources :users, :controller => "clearance/users" do |users|
    users.resource :password, :controller => "clearance/passwords", :only => [:create, :edit, :update]
    users.resource :confirmation, :controller => "clearance/confirmations", :only => [:new, :create]
  end
  map.valid_user "valid_user", :controller => "clearance/users", :action => :valid
  map.sign_up "sign_up", :controller => "clearance/users", :action => "new"
  map.sign_in "sign_in", :controller => "clearance/sessions", :action => "new"
  map.sign_out "sign_out", :controller => "clearance/sessions", :action => "destroy", :method => :delete
  map.goodbye "goodbye", :controller => "clearance/users", :action => "destroy"
  #MVR - user
  map.resources :users, :only => [] do |users|
    #MVR - user blogcasts
    users.resources "blogcasts", :controller => "users/blogcasts", :only => [:index, :show], :collection => {"recent" => :get, "upcoming" => :get}
    #MVR - user comments 
    users.resources "comments", :controller => "users/comments", :only => [:index]
    #MVR - users likes
    users.resources "likes", :controller => "users/likes", :only => [:index]
    #MVR - user subscriptions 
    users.resources "subscriptions", :controller => "users/subscriptions", :only => [:index]
    #MVR - user subscribers 
    users.resources "subscribers", :controller => "users/subscribers", :only => [:index]
  end
  #MVR - blogcasts
  map.blogcast_permalink ":username/:year/:month/:day/:title", :controller => "users/blogcasts", :action => "show", :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.username_blogcasts ":username/blogcasts.:format", :controller => "users/blogcasts", :format => nil
  map.user_blogcasts ":username/blogcasts.:format", :controller => "users/blogcasts", :format => nil
  map.username_recent_blogcasts ":username/blogcasts/recent.:format", :controller => "users/blogcasts", :action => "recent", :format => nil
  map.username_upcoming_blogcasts ":username/blogcasts/upcoming.:format", :controller => "users/blogcasts", :action => "upcoming", :format => nil
  #MVR - user search 
  map.user_search ":username/search", :controller => "users/search"
  #TODO: move everything over to use "user"
  #TODO 2: just use blogcast and not user
  map.user_tagged_blogcasts ":username/blogcasts/tagged.:format", :controller => "users/blogcasts", :action => "tagged", :format => nil
  #MVR - user blogcast
  map.username_blogcast_permalink ":username/:year/:month/:day/:title.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.user_blogcast_permalink ":username/:year/:month/:day/:title.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_permalink ":username/:year/:month/:day/:title.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.username_blogcast_posts_permalink ":username/:year/:month/:day/:title/posts.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.user_blogcast_posts_permalink ":username/:year/:month/:day/:title/posts.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_posts_permalink ":username/:year/:month/:day/:title/posts.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.username_blogcast_comments_permalink ":username/:year/:month/:day/:title/comments.:format", :controller => "users/blogcasts/comments", :action => "index", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_comments_permalink ":username/:year/:month/:day/:title/comments.:format", :controller => "users/blogcasts/comments", :action => "index", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.username_blogcast_likes_permalink ":username/:year/:month/:day/:title/likes.:format", :controller => "users/blogcasts/likes", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_likes_permalink ":username/:year/:month/:day/:title/likes.:format", :controller => "users/blogcasts/likes", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_search ":username/:year/:month/:day/:title/search", :controller => "search", :action => "blogcasts", :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  #MVR - user likes 
  map.username_likes ":username/likes.:format", :controller => "users/likes", :format => nil
  #MVR - user comments 
  map.username_comments ":username/comments.:format", :controller => "users/comments", :format => nil
  #MVR - user posts 
  map.username_posts ":username/posts.:format", :controller => "users/posts", :format => nil
  #MVR - user subscriptions
  map.username_subscriptions ":username/subscriptions.:format", :controller => "users/subscriptions", :format => nil
  #MVR - user subscribers
  map.username_subscribers ":username/subscribers.:format", :controller => "users/subscribers", :format => nil
  #MVR - user email notifications 
  map.username_email_notifications ":username/email_notifications", :controller => "email_user_notifications", :action => "create", :conditions => {:method => :post}
  map.username_email_notifications ":username/email_notifications", :controller => "email_user_notifications", :action => "destroy", :conditions => {:method => :delete}
  #MVR - user sms notifications 
  map.username_sms_notifications ":username/sms_notifications", :controller => "sms_user_notifications", :action => "create", :conditions => {:method => :post}
  map.username_sms_notifications ":username/sms_notifications", :controller => "sms_user_notifications", :action => "destroy", :conditions => {:method => :delete}
  #MVR - site 
  map.root :controller => "site"
  #MVR - site links
  map.about "about", :controller => "site", :action => "about"
  map.faq "faq", :controller => "site", :action => "faq"
  map.terms_of_service "terms_of_service", :controller => "site", :action => "terms_of_service"
  map.privacy_policy "privacy_policy", :controller => "site", :action => "privacy_policy"
  #MVR - search
  map.search "search", :controller => "search"
  #MVR - authentication token
  map.authentication_token "authentication_token.:format", :controller => "authentication_tokens", :action => "create", :method => "post", :format => nil
  #MVR - home
  map.home "home", :controller => "home"
  #MVR - messages 
  map.resources :messages, :controller => "messages", :only => [:index]
  #MVR - notifications 
  map.resources :notifications, :controller => "notifications", :only => [:index]
  #MVR - settings 
  map.resource :settings, :controller => "settings", :only => [:edit, :update]
  map.settings "settings", :controller => "settings", :action => "edit"
  map.account_settings "settings/account", :controller => "settings", :action => "account", :conditions => {:method => :post}
  map.appearance_settings "settings/appearance", :controller => "settings", :action => "appearance", :conditions => {:method => :post}
  map.blogcasts_settings "settings/blogcasts", :controller => "settings", :action => "blogcasts", :conditions => {:method => :post}
  map.connect_settings "settings/connect", :controller => "settings", :action => "connect", :conditions => {:method => :post}
  map.email_settings "settings/email", :controller => "settings", :action => "email", :conditions => {:method => :post}
  map.notifications_settings "settings/notifications", :controller => "settings", :action => "notifications", :conditions => {:method => :post}
  map.password_settings "settings/password", :controller => "settings", :action => "password", :conditions => {:method => :post}
  #MVR - subscriptions
  map.resources :subscriptions, :controller => "subscriptions", :only => [:index, :create, :destroy]
  #MVR - subscribed
  map.resources :subscribed, :controller => "subscribed", :only => [:index]
  #MVR - blogcasts
  map.create_blogcast "/blogcasts/create", :controller => "blogcasts", :action => "create"
  map.resources :blogcasts, :controller => "blogcasts", :only => [:new, :create, :show, :edit, :update, :destroy] do |blogcasts|
    #MVR - dashboard
    blogcasts.resource :dashboard, :controller => "dashboard", :only => [:show]
    #MVR - posts
    blogcasts.resources :posts, :controller => "posts", :only => [:destroy]
    #MVR - text posts
    blogcasts.resources :text_posts, :controller => "text_posts", :only => [:create]
    #MVR - image posts
    blogcasts.resources :image_posts, :controller => "image_posts", :only => [:create]
    #MVR - audio posts
    blogcasts.resources :audio_posts, :controller => "audio_posts", :only => [:create]
    #MVR - video posts
    blogcasts.resources :video_posts, :controller => "video_posts", :only => [:create]
    #MVR - comment posts
    blogcasts.resources :comment_posts, :controller => "comment_posts", :only => [:create, :destroy]
    #MVR - reposts
    blogcasts.resources :reposts, :controller => "reposts", :only => [:create, :destroy]
    #MVR - comments
    blogcasts.resources :comments, :controller => "comments", :only => [:create]
    #MVR - likes 
    blogcasts.resources :likes, :controller => "likes", :only => [:create, :destroy]
    #MVR - email reminders 
    blogcasts.resources :email_reminders, :controller => "email_blogcast_reminders", :only => [:create, :destroy]
    #MVR - sms reminders 
    blogcasts.resources :sms_reminders, :controller => "sms_blogcast_reminders", :only => [:create, :destroy]
    #MVR - update num viewers
    blogcasts.update_current_viewers "update_current_viewers", :controller => "viewers", :action => "update_current_viewers"
  end
  #MVR - posts 
  map.resources :posts, :controller => "posts", :only => [:index]
  #MVR - comments 
  map.resources :comments, :controller => "comments", :only => [:index]
  #MVR - likes 
  map.resources :likes, :controller => "likes", :only => [:index]
  #MVR - Facebook login
  map.facebook_logout "facebook_logout", :controller => "facebook_login", :action => "destroy", :method => "delete"
  map.facebook_login_redirect "facebook_login_redirect", :controller => "facebook_login", :action => "create"
  #MVR - Facebook connect
  map.resource :facebook_connect, :controller => "facebook_connect", :only => [:create, :destroy]
  #MVR - Twitter sign in 
  map.twitter_sign_out "twitter_sign_out", :controller => "twitter_sign_in", :action => "destroy", :method => "delete"
  map.twitter_sign_in_init "twitter_sign_in_init", :controller => "twitter_sign_in", :action => "init"
  map.twitter_sign_in_callback "twitter_sign_in_callback", :controller => "twitter_sign_in", :action => "create"
  #MVR - mobile phone
  map.resource :mobile_phone, :controller => "mobile_phone", :only => [:create, :destroy]
  map.confirm_mobile_phone "mobile_phone/confirm", :controller => "mobile_phone", :action => "confirm"
  #MVR - ejabberd
  map.ejabberd "ejabberd/:action.:format", :controller => "ejabberd"
  #MVR - profile
  map.profile ":username", :controller => "users/profile", :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
