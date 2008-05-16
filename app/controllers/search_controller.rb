class SearchController < ApplicationController
  def radius
    @location = Location.new(params[:location])
    @radius = params[:radius].to_d if params[:radius]
    @type = params[:type].to_d if params[:type]
    @radii = [1,5,10,25,50,100]
    @types = Type.find(:all)
    if(params[:location])
      @location.geocode
      @results = Location.find(:all, :origin => @location, :within => @radius)

      flash[:error] = "No locations matched your search" if @results.blank?
    end
  end
end
