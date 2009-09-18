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
  #MVR - Blogcastr 
  map.root :controller => "blogcastr"
  #MVR - dashboard
  map.dashboard "dashboard", :controller => "dashboard"
  #MVR - settings 
  map.resource :settings, :controller => "settings", :only => [:edit, :update]
  map.settings "settings", :controller => "settings", :action => "edit"
  #MVR - text posts
  map.resources "text_posts", :controller => "text_posts", :only => [:create, :destroy]
  #MVR - image posts
  map.resources "image_posts", :controller => "image_posts", :only => [:create, :destroy]
  #MVR - comment posts
  map.resources "comment_posts", :controller => "comment_posts", :only => [:create, :destroy]
  #MVR - reposts
  map.resources "reposts", :controller => "reposts", :only => [:create, :destroy]
  #MVR - blogcasts
  map.resources :blogcasts, :controller => "blogcasts", :only => [:show] do |blogcasts|
    #MVR - subscriptions
    blogcasts.resource :subscriptions, :controller => "subscriptions", :only => [:create, :destroy]
    #MVR - text comments
    blogcasts.resource :text_comments, :controller => "text_comments", :only => [:create]
    #MVR - image comments
    map.resources :image_comments, :controller => "image_comments", :only => [:create]
  end
  #MVR - Facebook sessions
  map.resource :facebook_session, :controller => "facebook_sessions", :only => [:create, :destroy]
  #MVR - Twitter sessions
  map.twitter_oauth_start "twitter_oauth_init", :controller => "twitter_sessions", :action => "init"
  map.twitter_oauth_callback "twitter_oauth_callback", :controller => "twitter_sessions", :action => "create"
  map.resource :twitter_session, :controller => "twitter_sessions", :only => [:destroy]
  #MVR - ejabberd
  map.ejabberd "ejabberd/:action.:format", :controller => "ejabberd"
  #MVR - blogcasts
  map.blogcast ":username", :controller => "blogcasts", :action => "show"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
