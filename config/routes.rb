ActionController::Routing::Routes.draw do |map|
  map.connect 'login', :controller => "sessions", :action => "new"
  map.connect 'signup', :controller => "users", :action => "new"
  map.connect 'logout', :controller => "sessions", :action => "destroy"

  map.resources :roles

  map.resources :affiliations, :has_one => :location, :has_one => :affiliate

  map.resources :locations

  map.resources :types

  map.resources :users

  map.resource :sessions

  # Map basic pages to home_controller
  map.root :controller => 'home'
  map.home ':page', :controller => 'home', :action => 'show',
    :page => /about|contact|what-is-go|validate/

  map.activate 'activate/:activation_code', :controller => 'users',
    :action => 'activate'

  map.connect 'go_clubs/:country/:state', :controller => 'locations', :action => 'index', :type => 'go_club', :country => nil, :state => nil

  map.connect 'search/:action', :controller => 'search'
  map.connect 'search/:type/:action', :controller => 'search'

  map.widgets '/widgets/:action', :controller => 'widgets'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
