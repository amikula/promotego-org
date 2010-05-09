class LocationsController < ApplicationController
  include GeoMethods

  before_filter :require_user, :only => [:new, :edit, :create, :update, :destroy]

  auto_complete_for :user, :login

  # GET /locations
  # GET /locations.xml
  def index
    # TODO Need to sort server-side so we can sort in the proper order for the translated country name.  In fact, if we're already doing that, then the following line is unnecessary.
    options = {:order => 'country, state, city, name'}

    if params[:country]
      country_name = seo_decode(params[:country])
      @country = I18n.t(country_name, :scope => :reverse_countries, :locale => host_locale) || country_name

      redirect_country = seo_encode better_translation(country_name, @country, :countries)

      if params[:state]
        state_name = seo_decode(params[:state])
        state = t(state_name, :scope => [:reverse_provinces, @country], :locale => host_locale) || state_name

        redirect_state = seo_encode better_translation(state_name, state, [:provinces, @country])

        redirect_to(:country => (redirect_country||params[:country]), :state => (redirect_state||params[:state]), :status => :moved_permanently) && return if redirect_country || redirect_state

        options[:conditions] = ['country = ? AND state = ?', @country, state]
        @heading = t 'clubs_in_location', :location => t(state, :scope => [:provinces, @country], :default => state_name)

        @title = t 'clubs_in_state_and_country', :state => state_name, :country => country_name
      else
        redirect_to(:country => redirect_country, :status => :moved_permanently) && return if redirect_country

        options[:conditions] = ['country = ?', @country]
        @heading = @title = t('clubs_in_location', :location => t(@country, :scope => :countries, :default => country_name))
      end
    end

    @locations = Location.visible.find(:all, options)

    @map = create_map(@locations, 1) unless @locations.blank?

    @locations.each do |location|
      pushpin_for_club(location, :link_club => true) if location.lat && location.lng
    end if @map

    respond_to do |format|
      format.html # index.html.haml
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
      format.html # new.html.haml
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
      flash[:error] = t 'club_unknown'
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
        flash[:notice] = t 'club_created'
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
        if (params[:location] && contacts = params[:location].delete(:contacts))
          contacts_array = hash_to_array(contacts)

          contacts_array.each do |contact|
            if (phones = contact.delete(:phone))
              contact[:phone] = hash_to_array(phones)
            end
          end

          @location.contacts = contacts_array
        end
        @location.attributes = params[:location]
        @location.geocode
      end

      if @location && @location.save
        flash[:notice] = t 'club_updated'
        format.html { redirect_to(location_path(@location.slug)) }
        format.xml  { head :ok }
      else
        format.html do
          if @location
            render :action => "edit"
          else
            flash[:error] = t 'club_unknown'
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

  def hash_to_array(hash)
    returning [] do |retval|
      hash.each_pair do |index, value|
        retval[index.to_i] = value
      end
    end
  end

  def better_translation(translation, key, scope, locale=host_locale)
    correct_translation = t(key, :scope => scope, :locale => locale)

    return correct_translation if correct_translation != translation
  end
end
