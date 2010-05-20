ActionController::Routing::Routes.draw do |map|
  map.resources :roles

  map.resources :affiliations, :has_one => :location, :has_one => :affiliate

  map.resources :locations do |location|
    location.resources :addresses
  end

  map.resource :account, :controller => "users"
  map.resources :users do |user|
    user.resources :addresses, :only => [:new, :create, :edit, :update, :destroy]
  end

  map.resource :forgot_password, :only => [:create, :show], :controller => 'forgot_password'
  map.resource :forgot_login, :only => [:create, :show], :controller => 'forgot_login'
  map.resources :reset_password, :only => [:update, :show], :controller => 'reset_password'

  map.resource :settings, :only => [:edit, :update]

  # Map basic pages to home_controller
  map.root :controller => 'home'
  map.home ':page', :controller => 'home', :action => 'show',
    :page => /about|contact|what-is-go|validate|credits|languages/

  map.activate 'activate/:activation_code', :controller => 'users',
    :action => 'activate'

  map.connect ':type/:country/:state', :controller => 'locations', :action => 'index', :country => nil, :state => nil, :type => /go-clubs|go_clubs/

  map.connect 'search/:action', :controller => 'search', :type => 'url-without-type'
  map.connect 'search/:type/:action.:format', :controller => 'search'
  map.connect 'search/:type/:action', :controller => 'search', :type => 'go-clubs'

  map.widgets '/widgets/:action', :controller => 'widgets'
  map.widgets '/widgets/:action.:format', :controller => 'widgets'

  map.resource :user_session, :member => {:destroy => :get}, :controller => :user_sessions
  #map.logout '/user_sessions/logout', :controller => :user_session, :action => :destroy

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
