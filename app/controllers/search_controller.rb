class SearchController < ApplicationController
  def radius
    @location = Location.new(params[:location])
    @radius = params[:radius].to_d if params[:radius]
    if params[:type]
      @type = Type.find_by_name(params[:type].gsub(/_/, ' ').singularize.titleize)
    elsif params[:type_id]
      # Todo turn this into a search for type by ID
      @type_id = params[:type_id].to_d if params[:type_id]
    end
    @radii = [1,5,10,25,50,100]
    @types = Type.find(:all)
    if(params[:location])
      @location.geocode
      find_params = {:origin => @location, :within => @radius}
      find_params.merge!(:conditions => ['type_id = ?', @type.id]) if @type
      @results = Location.find(:all, find_params)

      flash.now[:error] = "No locations matched your search" if @results.blank?
    end
  end
end
