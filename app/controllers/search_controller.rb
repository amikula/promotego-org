class SearchController < ApplicationController
  before_filter :go_clubs_redirect

  include GeoMethods

  SEARCH_RADII = [5,10,25,50,100,250]

  def go_clubs_redirect
    redirect_to :type => 'go-clubs', :action => params[:action], :status => :moved_permanently unless !request.get? || params[:type] == 'go-clubs'
  end

  def radius
    set_display_variables

    if(@address)
      @results = Location.find(:all, find_params)

      if (@results.blank?)
        find_closest
      end

      if !@results.blank?
        base_geo = geocode(@address)
        @map = create_map(@results.select{|r| r.is_a? Location} << base_geo)
        @results.each do |location|
          pushpin_for_club(location) if location.is_a? Location
        end
      else
        flash.now[:error] = "No locations matched your search within #{SEARCH_RADII[-1]} miles"
      end
    end
  end

  private
  def set_display_variables
    @address = params[:address]
    session[:last_search_address] = @address
    @radius = params[:radius].to_d if params[:radius]

    @radii = SEARCH_RADII
  end

  def find_params
    returning Hash.new do |find_params|
      find_params.merge!({:origin => @address, :within => @radius, :order => :distance})
      find_params[:conditions] = 'hidden = false'
    end
  end

  def find_closest
    closest_params = {:origin => @address, :within => SEARCH_RADII[-1]}
    closest_params[:conditions] = 'lat is not null and lng is not null and hidden = false'

    @closest = true

    @results = [Location.find_closest(closest_params)]
  end
end
