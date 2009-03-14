class LocationsController < ApplicationController
  ZOOM = {
    "unknown" => 6,
    "country" => 3,
    "state" => 6,
    "city" => 12,
    "zip" => 13,
    "zip+4" => 14,
    "street" => 14,
    "address" => 15
  }

  before_filter :login_required, :only => [:new, :edit, :create, :update, :destroy]

  auto_complete_for :user, :login

  # GET /locations
  # GET /locations.xml
  def index
    @locations = Location.visible.find(:all, :order => "country, state, city, name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = Location.find_by_slug(params[:id])

    respond_to do |format|
      format.html do
        @title = @location.name

        @map = GMap.new("map_div")
        @map.control_init(:large_map => true,:map_type => true)
        @map.center_zoom_init([@location.lat,@location.lng],
                              ZOOM[@location.geocode_precision || "unknown"])

        info_window = render_to_string :partial => "gmap_info_window",
          :locals => {:location => @location}
        info_window.gsub!(/\n/, '')
        info_window.gsub!('"', "'")

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
    render_contact_partials

    @location = Location.new
    @location.contacts = [{:phone => [{}]}]
    @types = Type.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    render_contact_partials

    @types = Type.find(:all)
    begin
      @location = if(current_user.has_role?(:administrator))
                    @location = Location.find_by_slug(params[:id])
                  else
                    @location = current_user.locations.find_by_slug(params[:id])
                  end
      @user = @location.user
    rescue ActiveRecord::RecordNotFound
      # just continue executing.  location doesn't exist.
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
        format.html { redirect_to(location_path(@location.slug)) }
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
    logger.debug params.inspect

    begin
      @location = if (current_user.has_role?(:administrator))
                    Location.find_by_slug(params[:id])
                  else
                    current_user.locations.find_by_slug(params[:id])
                  end
    rescue
      # Just continue -- no location found
    end

    if (current_user.has_role?(:administrator))
      unless params[:user].blank? || params[:user][:login].blank?
        new_owner = User.find_by_login(params[:user][:login])
        @location.change_user(new_owner.id, current_user)
      end
    end

    respond_to do |format|
      if @location
        @location.attributes = params[:location]
        @location.geocode
      end

      if @location && @location.save
        flash[:notice] = 'Location was successfully updated.'
        format.html { redirect_to(location_path(@location.slug)) }
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
    @location = current_user.locations.find_by_slug(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end

  private
  def render_contact_partials
    @contact_form = render_to_string(:partial => 'contact_form', :locals => {:contact_idx => 'CONTACT_IDX', :contact => {:phone => [{}]}}).gsub(/\n/, '\n').gsub(/'/, '"')
    @phone_form = render_to_string(:partial => 'phone_number_form', :locals => {:phone => {}, :contact_idx => 'CONTACT_IDX', :phone_idx => 'PHONE_IDX'}).gsub(/\n/, '\n').gsub(/'/, '"')
  end
end
