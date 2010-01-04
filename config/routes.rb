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
  map.sign_up  "sign_up", :controller => "clearance/users", :action => "new"
  map.sign_in  "sign_in", :controller => "clearance/sessions", :action => "new"
  map.sign_out "sign_out", :controller => "clearance/sessions", :action => "destroy", :method => :delete
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
  #MVR - user blogcasts
  map.user_name_blogcasts ":user_name/blogcasts.:format", :controller => "users/blogcasts", :format => nil
  map.user_name_recent_blogcasts ":user_name/blogcasts/recent.:format", :controller => "users/blogcasts", :action => "recent", :format => nil
  map.user_name_upcoming_blogcasts ":user_name/blogcasts/upcoming.:format", :controller => "users/blogcasts", :action => "upcoming", :format => nil
  #MVR - user blogcast
  map.user_name_blogcast_permalink ":user_name/:year/:month/:day/:title.:format", :controller => "users/blogcasts", :action => "show", :format => nil, :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  #MVR - user likes 
  map.user_name_likes ":user_name/likes.:format", :controller => "users/likes", :format => nil
  #MVR - user comments 
  map.user_name_comments ":user_name/comments.:format", :controller => "users/comments", :format => nil
  #MVR - user posts 
  map.user_name_posts ":user_name/posts.:format", :controller => "users/posts", :format => nil
  #MVR - user subscriptions
  map.user_name_subscriptions ":user_name/subscriptions.:format", :controller => "users/subscriptions", :format => nil
  #MVR - user subscribers
  map.user_name_subscribers ":user_name/subscribers.:format", :controller => "users/subscribers", :format => nil
  #MVR - site 
  map.root :controller => "site"
  #MVR - site links
  map.about "about", :controller => "site", :action => "about"
  map.faq "faq", :controller => "site", :action => "faq"
  map.terms_of_service "terms_of_service", :controller => "site", :action => "terms_of_service"
  map.privacy_policy "privacy_policy", :controller => "site", :action => "privacy_policy"
  #MVR - search
  map.search "search", :controller => "search"
  map.user_search ":user_name/search.:format", :controller => "search", :action => "user"
  #MVR - authentication token
  map.authentication_token "authentication_token.:format", :controller => "authentication_tokens", :action => "create", :method => "post", :format => nil
  #MVR - home
  map.home "home", :controller => "home"
  #MVR - settings 
  map.resource :settings, :controller => "settings", :only => [:edit, :update]
  map.settings "settings", :controller => "settings", :action => "edit"
  #MVR - subscriptions
  map.resources :subscriptions, :controller => "subscriptions", :only => [:index, :create, :destroy]
  #MVR - subscribed
  map.resources :subscribed, :controller => "subscribed", :only => [:index]
  #MVR - blogcasts
  map.create_blogcast "/blogcasts/create", :controller => "blogcasts", :action => "create"
  map.resources :blogcasts, :controller => "blogcasts", :only => [:new, :create, :show, :edit, :update, :destroy] do |blogcasts|
    #MVR - dashboard
    blogcasts.resource :dashboard, :controller => "dashboard", :only => [:show]
    #MVR - text posts
    blogcasts.resources :text_posts, :controller => "text_posts", :only => [:create, :destroy]
    #MVR - image posts
    blogcasts.resources :image_posts, :controller => "image_posts", :only => [:create, :destroy]
    #MVR - comment posts
    blogcasts.resources :comment_posts, :controller => "comment_posts", :only => [:create, :destroy]
    #MVR - reposts
    blogcasts.resources :reposts, :controller => "reposts", :only => [:create, :destroy]
    #MVR - text comments
    blogcasts.resources :comments, :controller => "comments", :only => [:create]
    #MVR - image comments
    blogcasts.resources :image_comments, :controller => "image_comments", :only => [:create]
    #MVR - likes 
    blogcasts.resources :likes, :controller => "likes", :only => [:create, :destroy]
  end
  #AS DESIGNED: map 
  #map.edit_blogcast "/blogcasts/:year/:month/:day/:title/edit", :controller => "dashboard", :action => "edit" 
  #map.blogcast_dashboard "/blogcasts/:year/:month/:day/:title/dashboard", :controller => "dashboard", :action => "show" 
  #MVR - subscriptions
  #map.resources :users, :controller => "clearance/users",  :only => [] do |users|
  #  users.resource :subscription, :controller => "subscriptions", :only => [:index, :create, :destroy]
  #  users.resources :subscribed, :controller => "subscribed", :only => [:index]
 # end
  #MVR - Facebook sessions
  map.resource :facebook_session, :controller => "facebook_sessions", :only => [:create, :destroy]
  #MVR - Twitter sessions
  map.twitter_oauth_start "twitter_oauth_init", :controller => "twitter_sessions", :action => "init"
  map.twitter_oauth_callback "twitter_oauth_callback", :controller => "twitter_sessions", :action => "create"
  map.resource :twitter_session, :controller => "twitter_sessions", :only => [:destroy]
  #MVR - ejabberd
  map.ejabberd "ejabberd/:action.:format", :controller => "ejabberd"
  #MVR - profile
  map.profile ":username", :controller => "profile", :action => "index"
  #MVR - public blogcasts
  map.public_blogcasts ":username/blogcasts", :controller => ":blogcasts", :action => "index"
  #MVR - RSS
  map.rss ":username/blogcasts.rss", :controller => ":blogcasts", :action => "rss"
  #MVR - public subscriptions 
  map.public_subscriptions ":username/subscriptions", :controller => ":subscriptions", :action => "index"
  #MVR - public subscribers 
  map.public_subscribers ":username/subscribers", :controller => ":subscribers", :action => "index"
  #MVR - public posts 
  map.public_posts ":username/posts", :controller => ":posts", :action => "index"
  #MVR - blogcasts
  #TODO: decide if this should include the date
  #map.blogcast "/:username/:year/:month/:day/:title", :controller => "blogcasts", :action => "show",  map.full_blogcast "/:username/:year/:month/:day/:title", :controller => "blogcasts", :action => "show"
  map.blogcast_permalink ":username/:year/:month/:day/:title", :controller => "blogcasts", :action => "permalink", :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  #TODO: make these part of each individual controller
  map.blogcast_posts_permalink ":username/:year/:month/:day/:title/posts", :controller => "blogcasts", :action => "posts_permalink", :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_comments_permalink ":username/:year/:month/:day/:title/comments", :controller => "blogcasts", :action => "comments_permalink", :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}
  map.blogcast_likes_permalink ":username/:year/:month/:day/:title/likes", :controller => "blogcasts", :action => "likes_permalink", :requirements => {:year => /20\d\d/, :month => /1?\d/, :day => /[1-3]?\d/}

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
