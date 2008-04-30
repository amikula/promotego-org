require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  describe "handling GET /locations" do

    before(:each) do
      @location = mock_model(Location)
      Location.stub!(:find).and_return([@location])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all locations" do
      Location.should_receive(:find).with(:all).and_return([@location])
      do_get
    end
  
    it "should assign the found locations for the view" do
      do_get
      assigns[:locations].should == [@location]
    end
  end

  describe "handling GET /locations.xml" do

    before(:each) do
      @location = mock_model(Location, :to_xml => "XML")
      Location.stub!(:find).and_return(@location)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all locations" do
      Location.should_receive(:find).with(:all).and_return([@location])
      do_get
    end
  
    it "should render the found locations as xml" do
      @location.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /locations/1" do

    before(:each) do
      @location = mock_model(Location)
      Location.stub!(:find).and_return(@location)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the location requested" do
      Location.should_receive(:find).with("1").and_return(@location)
      do_get
    end
  
    it "should assign the found location for the view" do
      do_get
      assigns[:location].should equal(@location)
    end
  end

  describe "handling GET /locations/1.xml" do

    before(:each) do
      @location = mock_model(Location, :to_xml => "XML")
      Location.stub!(:find).and_return(@location)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the location requested" do
      Location.should_receive(:find).with("1").and_return(@location)
      do_get
    end
  
    it "should render the found location as xml" do
      @location.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /locations/new" do

    before(:each) do
      @location = mock_model(Location)
      Location.stub!(:new).and_return(@location)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new location" do
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
  end

  describe "handling GET /locations/1/edit" do

    before(:each) do
      @location = mock_model(Location)
      Location.stub!(:find).and_return(@location)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the location requested" do
      Location.should_receive(:find).and_return(@location)
      do_get
    end
  
    it "should assign the found Location for the view" do
      do_get
      assigns[:location].should equal(@location)
    end
  end

  describe "handling POST /locations" do

    before(:each) do
      @location = mock_model(Location, :to_param => "1")
      Location.stub!(:new).and_return(@location)
    end
    
    describe "with successful save" do
  
      def do_post
        @location.should_receive(:save).and_return(true)
        post :create, :location => {}
      end
  
      it "should create a new location" do
        Location.should_receive(:new).with({}).and_return(@location)
        do_post
      end

      it "should redirect to the new location" do
        do_post
        response.should redirect_to(location_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @location.should_receive(:save).and_return(false)
        post :create, :location => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /locations/1" do

    before(:each) do
      @location = mock_model(Location, :to_param => "1")
      Location.stub!(:find).and_return(@location)
    end
    
    describe "with successful update" do

      def do_put
        @location.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the location requested" do
        Location.should_receive(:find).with("1").and_return(@location)
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
        response.should redirect_to(location_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @location.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /locations/1" do

    before(:each) do
      @location = mock_model(Location, :destroy => true)
      Location.stub!(:find).and_return(@location)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the location requested" do
      Location.should_receive(:find).with("1").and_return(@location)
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
end