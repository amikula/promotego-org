ActionController::Routing::Routes.draw do |map|
  map.connect 'login', :controller => "sessions", :action => "new"
  map.connect 'signup', :controller => "users", :action => "new"
  map.connect 'logout', :controller => "sessions", :action => "destroy"

  map.resources :roles

  map.resources :affiliations, :has_one => :location, :has_one => :affiliate

  map.resources :locations

  map.resources :users

  map.resource :sessions

  # Map basic pages to home_controller
  map.root :controller => 'home'
  map.home ':page', :controller => 'home', :action => 'show',
    :page => /about|contact|what-is-go|validate/

  map.activate 'activate/:activation_code', :controller => 'users',
    :action => 'activate'

  map.connect ':type/:country/:state', :controller => 'locations', :action => 'index', :country => nil, :state => nil, :type => /go-clubs|go_clubs/

  map.connect 'search/:action', :controller => 'search', :type => 'url-without-type'
  map.connect 'search/:type/:action.:format', :controller => 'search'
  map.connect 'search/:type/:action', :controller => 'search', :type => 'go-clubs'

  map.widgets '/widgets/:action', :controller => 'widgets'
  map.widgets '/widgets/:action.:format', :controller => 'widgets'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
