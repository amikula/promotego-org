class SearchController < ApplicationController
  def radius
    @address = params[:address]
    @radius = params[:radius].to_d if params[:radius]
    if params[:type]
      @type = Type.find_by_name(params[:type].gsub(/_/, ' ').singularize.titleize)
      unless @type
        flash[:error] = "Type '#{params[:type]}' is invalid."
        redirect_to :action => :radius
        return
      end

      @type_id = @type.id
    elsif params[:type_id]
      @type_id = params[:type_id].to_d if params[:type_id]
    end

    @radii = [5,10,25,50,100]
    @types = Type.find(:all)
    if(@address)
      find_params = {:origin => @address, :within => @radius,
        :order => :distance}
      if @type_id && @type_id > 0
        find_params[:conditions] = ['type_id = ?', @type_id]
      end

      @results = Location.find(:all, find_params)

      if (@results.blank?)
        closest_params = {:origin => @address, :within => 100}
        if (@type_id && @type_id > 0)
          closest_params[:conditions] = ['lat is not null and lng is not null and type_id = ?', @type_id]
        else
          closest_params[:conditions] = 'lat is not null and lng is not null'
        end

        @closest = Location.find_closest(closest_params)
      end

      if @results.blank? && @closest.blank?
        flash.now[:error] = "No locations matched your search within 100 miles"
      end
    end
  end
end
