class SearchController < ApplicationController
  include GeoMethods

  SEARCH_RADII = {:mi => [5,10,25,50,100,250], :km => [10,25,50,100,250,400]}

  def radius
    @title = "Find a Go Club"

    set_display_variables
    @closest = false

    if(@address)
      @results = Location.find(:all, find_params)

      if (@results.blank?)
        find_closest
      end

      respond_to do |format|
        format.html do
          if !@results.blank?
            base_geo = geocode(@address)
            @map = create_map(@results.select{|r| r.is_a? Location} << base_geo)
            @results.each do |location|
              pushpin_for_club(location) if location.is_a? Location
            end
          else
            flash.now[:error] = t 'no_clubs_matched_limit', :limit => SEARCH_RADII[distance_units].last, :scope => distance_units
          end
        end

        format.js{render :json => {:autoexpand => @closest, :results => @results}.to_json(:except => :foreign_key)}
      end
    end
  end

  private
  def set_display_variables
    @address = params[:address]
    session[:last_search_address] = @address
    @radius = params[:radius].to_d if params[:radius]

    @radii = SEARCH_RADII[distance_units]
  end

  def find_params
    returning Hash.new do |find_params|
      find_params.merge!({:origin => @address, :within => @radius, :order => :distance})
      find_params[:conditions] = 'hidden = false'
    end
  end

  def find_closest
    limit = SEARCH_RADII[distance_units].last
    limit = limit.send(distance_units).to.miles.to_f unless distance_units == :mi

    closest_params = {:origin => @address, :within => limit}
    closest_params[:conditions] = 'lat is not null and lng is not null and hidden = false'

    @closest = true

    @results = [Location.find_closest(closest_params)].compact
  end
end
