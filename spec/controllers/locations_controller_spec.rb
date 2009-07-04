require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  before(:each) do
    @user = mock_model(User, :name => "Test User", :login => "testuser")
    @user.stub!(:has_role?).and_return(false)
    @user.stub!(:locations).and_return(:locations)
    @other_user = mock_model(User, :name => "Other User",
                             :login => 'otheruser')
    @controller.stub!(:current_user).and_return(@user)
  end

  describe "handling GET /locations" do

    before(:each) do
      @location = mock_model(Location, :lat => 0, :lng => 0)
      Location.stub!(:find).and_return([@location])
    end

    def do_get(options={})
      get :index, options.reverse_merge(:type => 'go-clubs')
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all visible locations" do
      visible = mock('named_scope', :find => [@location])
      Location.should_receive(:visible).and_return(visible)
      do_get
    end

    it "should assign the found locations for the view" do
      do_get
      assigns[:locations].should == [@location]
    end

    it "filters by country when a country is provided" do
      visible = mock('named_scope')
      visible.should_receive(:find).with(:all, hash_including(:conditions => ['country = ?', 'GB'])).and_return([])
      Location.should_receive(:visible).and_return(visible)

      do_get :country => 'United-Kingdom'
    end

    it "filters by country and state when a country and state are provided" do
      visible = mock('named_scope')
      visible.should_receive(:find).with(:all, hash_including(:conditions => ['country = ? AND state = ?', 'US', 'TX'])).and_return([])
      Location.should_receive(:visible).and_return(visible)

      do_get :country => 'United-States', :state => 'Texas'
    end

    it "assigns fields for global view" do
      do_get

      assigns[:fields].should == [:city, :state, :country]
    end

    it "assigns fields for country view" do
      do_get :country => 'United-States'

      assigns[:fields].should == [:city, :state]
    end

    it "assigns fields for state view" do
      do_get :country => 'United-States', :state => 'Texas'

      assigns[:fields].should == [:street_address, :city]
    end
  end

  describe "handling GET /locations.xml" do

    before(:each) do
      @locations = [mock_model(Location, :to_xml => "XML", :lat => 0, :lng => 0)]
      Location.stub!(:find).and_return(@locations)
    end

    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index, :type => 'go-clubs'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all locations" do
      do_get
    end

    it "should render the found locations as xml" do
      @locations.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe :show do
    describe "handling GET /locations/location-name" do

      before(:each) do
        @location = mock_model(Location, :geocode_precision => "city",
                               :name => "Location Name", :lat => 0, :lng => 0,
                               :street_address => 'Location Address',
                               :city => "City",
                               :state => "State", :zip_code => "00000",
                               :country => "USA",
                               :slug => 'location-name',
                               :city_state_zip => "City, State 00000")
        Location.stub!(:find_by_slug).and_return(@location)
      end

      def do_get(options={})
        get :show, {:id => "location-name"}.merge(options)
      end

      it "is successful" do
        do_get
        response.should be_success
      end

      it "finds the location requested" do
        Location.should_receive(:find_by_slug).with("location-name").and_return(@location)
        do_get
      end

      it "assigns the found location for the view" do
        do_get
        assigns[:location].should equal(@location)
      end

      it "sets the page title to the location name" do
        do_get
        assigns[:title].should == @location.name
      end

      it "throws ActiveRecord::RecordNotFound when the slug isn't found" do
        Location.should_receive(:find_by_slug).and_return(nil)

        lambda{do_get}.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "redirects to the proper record when slug isn't found and SlugRedirect exists" do
        Location.should_receive(:find_by_slug).and_return(nil)
        redirect_location = mock_model(Location, :slug => 'correct_slug')
        slug_redirect = mock_model(SlugRedirect, :slug => 'old_slug', :location => redirect_location)
        SlugRedirect.should_receive(:find_by_slug).with('old_slug').and_return(slug_redirect)

        do_get :id => 'old_slug'

        response.response_code.should == 301
        response.should redirect_to(location_path('correct_slug'))
      end
    end

    describe "handling GET /locations/location-name.xml" do

      before(:each) do
        @location = mock_model(Location, :to_xml => "XML")
        Location.stub!(:find_by_slug).and_return(@location)
      end

      def do_get
        @request.env["HTTP_ACCEPT"] = "application/xml"
        get :show, :id => "location-name"
      end

      it "should be successful" do
        do_get
        response.should be_success
      end

      it "should find the location requested" do
        Location.should_receive(:find_by_slug).with("location-name").and_return(@location)
        do_get
      end

      it "should render the found location as xml" do
        @location.should_receive(:to_xml).and_return("XML")
        do_get
        response.body.should == "XML"
      end
    end
  end

  describe "handling GET /locations/new" do

    before(:each) do
      @location = mock_model(Location)
      Location.stub!(:new).and_return(@location)
      @location.stub!(:contacts=)
    end

    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should create a new location" do
      Location.should_receive(:new).and_return(@location)
      do_get
    end

    it "should not save the new location" do
      @location.should_not_receive(:save)
      do_get
    end

    it "should assign the new location for the view" do
      do_get
      assigns[:location].should equal(@location)
    end

    it "should contain an empty contact object" do
      @location.should_receive(:contacts=).with([{:phone => [{}]}])
      do_get
    end
  end

  describe "handling GET /locations/1/edit" do

    before(:each) do
      @locations = []
      @user.should_receive(:locations).and_return(@locations)
      owner = mock_model(User, :login => "login")
      @location = mock_model(Location, :user => owner, :slug => 'location-slug')
      @locations.stub!(:find_by_slug).with(@location.slug).and_return(@location)
    end

    def do_get
      get :edit, :id => @location.slug
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should assign @user to be owner of the current location" do
      do_get
      assigns[:user].should equal(@location.user)
    end

    it "should assign the found Location for the view" do
      do_get
      assigns[:location].should equal(@location)
    end
  end

  describe "handling POST /locations" do

    before(:each) do
      @location = mock_model(Location, :to_param => "1", :slug => 'location-slug')
      @location.stub!(:user=)
      Location.stub!(:new).and_return(@location)
    end

    describe "with successful save" do

      def do_post
        @location.should_receive(:save).and_return(true)
        @location.should_receive(:geocode)
        post :create, :location => {}
      end

      it "should create a new location" do
        Location.should_receive(:new).with({}).and_return(@location)
        do_post
      end

      it "should redirect to the new location's slug" do
        do_post
        response.should redirect_to(location_path('location-slug'))
      end

      it "should save the current user as the location's owner" do
        @location.should_receive(:user=).with(@user)
        do_post
      end

      it "should save the user value posted if current user is administrator" do
        @user.should_receive(:has_role?).with(:administrator).and_return(true)

        @location.should_receive(:user_id=).with(@other_user.id)
        @location.should_receive(:save).and_return(true)
        @location.should_receive(:geocode)
        post :create, :location => {:user_id => @other_user.id}
      end
    end

    describe "with failed save" do

      def do_post
        @location.should_receive(:save).and_return(false)
        post :create, :location => {}
      end

      it "should re-render 'new'" do
        @location.stub!(:geocode)
        do_post
        response.should render_template('new')
      end

    end
  end

  describe "handling PUT /locations/1" do

    before(:each) do
      @location = mock_model(Location, :to_param => "1", :slug => 'location-slug')
      @locations = [@location]
      @locations.stub!(:find_by_slug).with(@location.slug).and_return(@location)
      @user.stub!(:locations).and_return(@locations)
    end

    describe "with successful update" do

      def do_put
        @location.should_receive(:attributes=)
        @location.should_receive(:geocode)
        @location.should_receive(:save).and_return(true)
        put :update, :id => @location.slug
      end

      it "should find the location requested" do
        @locations.should_receive(:find_by_slug).with(@location.slug).and_return(@location)
        do_put
      end

      it "should update the found location" do
        do_put
        assigns(:location).should equal(@location)
      end

      it "should assign the found location for the view" do
        do_put
        assigns(:location).should equal(@location)
      end

      it "should redirect to the location" do
        do_put
        response.should redirect_to(location_path('location-slug'))
      end

      it "should re-geocode the location" do
        @location.should_receive(:attributes=).ordered.and_return(true)
        @location.should_receive(:geocode).ordered
        @location.should_receive(:save).ordered
        put :update, :id => @location.slug
      end

      it "should save the user value posted if current user is administrator" do
        Location.should_receive(:find_by_slug).with(@location.slug).and_return(@location)
        User.should_receive(:find_by_login).with(@other_user.login).
          and_return(@other_user)

        @user.stub!(:has_role?).with(:administrator).and_return(true)

        @location.should_receive(:change_user).with(@other_user.id, @user)
        @location.should_receive(:attributes=)
        @location.should_receive(:geocode)
        @location.should_receive(:save).and_return(true)

        put :update, :id => @location.slug, :user => {:login => @other_user.login}
      end
    end

    describe "with failed update" do

      def do_put
        @location.should_receive(:attributes=)
        @location.should_receive(:geocode)
        @location.should_receive(:save).and_return(false)
        put :update, :id => @location.slug
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /locations/1" do

    before(:each) do
      @location = mock_model(Location, :destroy => true, :slug => 'location-slug')
      @locations = [@location]

      @user.should_receive(:locations).and_return(@locations)
      @locations.should_receive(:find_by_slug).with(@location.slug).and_return(@location)
    end

    def do_delete
      delete :destroy, :id => @location.slug
    end

    it "should find the location requested" do
      do_delete
    end

    it "should call destroy on the found location" do
      @location.should_receive(:destroy)
      do_delete
    end

    it "should redirect to the locations list" do
      do_delete
      response.should redirect_to(locations_url)
    end
  end

  describe "with normal user access" do
    before(:each) do
      @location = mock_model(Location, :user => @user, :slug => 'location-slug')
      @locations = [@location]
      @user.should_receive(:locations).and_return(@locations)
    end

    describe "accessing edit form" do
      it "should allow access to user's own locations" do
        @locations.should_receive(:find_by_slug).with(@location.slug).and_return(@location)
        get :edit, :id => @location.slug

        response.should be_success
        assigns[:location].should == @location
      end

      it "should not allow access to other users' locations" do
        location = mock_model(Location, :user => @other_user, :slug => 'location-slug')
        @locations.should_receive(:find_by_slug).with(location.slug).and_raise(ActiveRecord::RecordNotFound.new("RSpec test exception"))

        get :edit, :id => location.slug

        response.should redirect_to(locations_url)
        flash[:error].should == 'Location does not exist'
      end
    end

    describe "updating location" do
      it "should work for user's own locations" do
        @locations.should_receive(:find_by_slug).with(@location.slug).and_return(@location)
        @location.should_receive(:attributes=)
        @location.should_receive(:geocode)
        @location.should_receive(:save).and_return(true)

        put :update, :id => @location.slug

        response.should redirect_to(location_path('location-slug'))
      end

      it "should not work for other users' locations" do
        location = mock_model(Location, :user => @other_user, :slug => 'location-slug')
        @locations.should_receive(:find_by_slug).with(location.slug).and_raise(ActiveRecord::RecordNotFound.new("RSpec test exception"))

        put :update, :id => location.slug

        response.should redirect_to(locations_url)
        flash[:error].should == 'Location does not exist'
      end
    end
  end

  describe "with administrative user access" do
    before(:each) do
      @user.stub!(:has_role?).with(:administrator).and_return(true)
      @location = mock(Location, :user => @user, :slug => 'location-slug')
      Location.stub!(:find_by_slug).with(@location.slug).and_return(@location)
    end

    it "should list all locations in locations list, regardless of ownership" do
      all_locations = []
      Location.should_receive(:find).with(:all, anything).and_return(all_locations)

      get :index, :type => 'go-clubs'

      assigns(:locations).should == all_locations
    end

    it "should allow access to edit form for all locations" do
      get :edit, :id => @location.slug

      response.should be_success
      assigns[:location].should == @location
    end

    it "should allow saving of all locations" do
      @location.should_receive(:attributes=)
      @location.should_receive(:geocode)
      @location.should_receive(:save).and_return(true)

      put :update, :id => @location.slug

      response.should redirect_to(location_path('location-slug'))
    end
  end

  it "should have auto_complete_for_user_login" do
    get :auto_complete_for_user_login, :user => {:login => "foo"}
  end
end
