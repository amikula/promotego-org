class LocationsController < ApplicationController
  include GeoMethods

  before_filter :login_required, :only => [:new, :edit, :create, :update, :destroy]

  auto_complete_for :user, :login

  # GET /locations
  # GET /locations.xml
  def index
    unless params[:type] == 'go-clubs'
      redirect_to :action => :index, :country => params[:country], :state => params[:state], :type => 'go-clubs'
      return
    end

    options = {:order => 'country, state, city, name'}

    if params[:country]
      country_name = params[:country].gsub('-', ' ')
      country = COUNTRY_TO_ABBREV[country_name] || params[:country]

      if params[:state]
        state_name = params[:state].gsub('-', ' ')
        if STATE_TO_ABBREV[country]
          state = STATE_TO_ABBREV[country][state_name]
        end
        state ||= state_name

        options[:conditions] = ['country = ? AND state = ?', country, state]
        @locality = "in #{state_name}"
        @fields = [:street_address, :city]

        @title = "Go Clubs in #{state_name}, #{country_name}"
      else
        options[:conditions] = ['country = ?', country]
        @locality = "in #{country_name}"
        @fields = [:city, :state]
        @title = "Go Clubs in #{country_name}"
      end
    else
      @fields = [:city, :state, :country]
    end

    @locations = Location.visible.find(:all, options)

    @map = create_map(@locations, 1) unless @locations.blank?

    @locations.each do |location|
      pushpin_for_club(location, :link_club => true) if location.lat && location.lng
    end if @map

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    slug = params[:id]
    @location = Location.find_by_slug(slug)

    unless @location
      slug_redirect = SlugRedirect.find_by_slug(slug)

      if slug_redirect
        redirect_to location_path(slug_redirect.location.slug), :status => :moved_permanently and return
      end

      raise ActiveRecord::RecordNotFound.new("No such club: #{params[:id]}")
    end

    respond_to do |format|
      format.html do
        @title = @location.name

        @map = create_map(@location)

        pushpin_for_club(@location, :show_info_window => true) if @map
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    render_contact_partials

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
    @contact_form = render_to_string(:partial => 'contact_form',
                                     :locals => {:javascript => true, :contact_idx => 'CONTACT_IDX',
                                                 :contact => {:phone => [{}]}}).gsub(/\n/, '\n').gsub(/'/, '"')
    @phone_form = render_to_string(:partial => 'phone_number_form', :locals => {:phone => {}, :contact_idx => 'CONTACT_IDX', :phone_idx => 'PHONE_IDX'}).gsub(/\n/, '\n').gsub(/'/, '"')
  end
end
