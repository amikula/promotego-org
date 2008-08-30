class LocationsController < ApplicationController
  before_filter :login_required, :only => [:new, :edit, :create, :update, :destroy]

  auto_complete_for :user, :login

  # GET /locations
  # GET /locations.xml
  def index
    @locations = Location.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html do
        @map = GMap.new("map_div")
        @map.control_init(:large_map => true,:map_type => true)
        if(@location.precision == :address)
          @map.center_zoom_init([@location.lat,@location.lng],15)
        else
          @map.center_zoom_init([@location.lat,@location.lng],12)
        end

        info_window = render_to_string :partial => "gmap_info_window",
          :locals => {:location => @location}
        info_window.gsub!(/\n/, '')

        club = GMarker.new([@location.lat,@location.lng],
                           :info_window => info_window)
        @map.record_global_init(club.declare("club"))
        @map.overlay_init(club)
        @map.record_init("club.openInfoWindowHtml(\"#{club.info_window}\");\n")
      end
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new
    @types = Type.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @types = Type.find(:all)
    if(current_user.has_role?(:administrator))
      @location = Location.find(params[:id])
    else
      @location = current_user.locations.find(params[:id])
    end

    unless @location
      flash[:error] = 'Location does not exist'
      redirect_to locations_url
    end
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(params[:location])
    @location.geocode
    if(current_user.has_role?(:administrator) && params[:location][:user_id])
      @location.user_id = params[:location][:user_id]
    else
      @location.user = current_user
    end

    respond_to do |format|
      if @location.save
        flash[:notice] = 'Location was successfully created.'
        format.html { redirect_to(@location) }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    if (current_user.has_role?(:administrator))
      @location = Location.find(params[:id])
      if params[:location] && params[:location][:user_id]
        @location.change_user(params[:location][:user_id], current_user)
      end
    else
      @location = current_user.locations.find(params[:id])
    end

    respond_to do |format|
      if @location
        @location.attributes = params[:location]
        @location.geocode
      end

      if @location && @location.save
        flash[:notice] = 'Location was successfully updated.'
        format.html { redirect_to(@location) }
        format.xml  { head :ok }
      else
        format.html do
          if @location
            render :action => "edit"
          else
            flash[:error] = 'Location does not exist'
            redirect_to locations_url
          end
        end
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = current_user.locations.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end
end
