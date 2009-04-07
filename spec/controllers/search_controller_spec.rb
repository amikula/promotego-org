require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  before(:each) do
    @address = "169 N. Berkeley Ave., Pasadena, CA"
    @location = mock_location(:geocode_precision => "address", :geocode_address => "123 Fake Lane, City, State", :lat =>0, :lng => 0)
  end

  describe :radius do
    it "should assign radii and types on radius_search" do
      get :radius
      assigns[:location]
      assigns[:radii]
      assigns[:types]
    end

    it "should find the closest result if no search results are present" do
      Location.should_receive(:find).and_return([])

      Location.should_receive(:find_closest).with(:origin => @address,
          :within => 100, :conditions => 'lat is not null and lng is not null and hidden = false')

      get :radius, :address => @address, :radius => "5"
    end

    it "should call find with the results of the find_params method" do
      controller.should_receive(:find_params).and_return(:find_params)
      Location.should_receive(:find).with(:all, :find_params).and_return([@location])

      get :radius, :address => @address, :radius => "5"
    end

    describe "with type" do
      it 'should not raise error when type is invalid' do
        Location.stub!(:find).and_return([])
        lambda{get :radius, :type => "bogus_type", :radius => "5", :address => @address}.should_not raise_error
      end

      it "should find the closest result if no search results are present" do
        go_club = mock_model(Type, :name => "Go Club")

        Location.should_receive(:find).and_return([])

        closest = stub_model(Location)
        Location.should_receive(:find_closest).
          with(:origin => @address, :within => 100,
               :conditions => ['lat is not null and lng is not null and hidden = false and type_id = ?', go_club.id]).
               and_return(closest)

        get :radius, :type_id => go_club.id, :radius => "5",
          :address => @address

        assigns[:closest].should == closest
      end
    end

    describe "should add location headings" do
      it "when results have no address" do
        view_results = [
          Location::LocationHeader.new("City, State", :city, "4.1"),
          mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "city", :geocode_address => "City, State", :distance => "4.1", :lat => 0, :lng => 0),
          mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => "City, State", :distance => "4.1", :lat => 0, :lng => 0)
        ]

        db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

        Location.should_receive(:find).and_return(db_results)

        get :radius, :radius => "5", :address => '00000'

        assigns[:results].should == view_results
      end

      it "when results have addresses, use average distance" do
        view_results = [
          Location::LocationHeader.new("City, State", :city, "4.1"),
          mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City, State', :distance => "4.0", :lat => 0, :lng => 0),
          mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "address", :geocode_address => '123 Sesame St., City, State', :distance => "4.2", :lat => 0, :lng => 0)
        ]

        db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

        Location.should_receive(:find).and_return(db_results)

        get :radius, :radius => "5", :address => '00000'

        assigns[:results].should == view_results
      end

      it "when some results have addresses and some don't" do
        view_results = [
          Location::LocationHeader.new("City, State", :city, "4.2"),
          mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City, State', :distance => "4.0", :lat => 0, :lng => 0),
          mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => 'City, State', :distance => "4.2", :lat => 0, :lng => 0)
        ]

        db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

        Location.should_receive(:find).and_return(db_results)

        get :radius, :radius => "5", :address => '00000'

        assigns[:results].should == view_results
      end

      it "for each city" do
        view_results = [
          Location::LocationHeader.new("City, State", :city, "4.2"),
          mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City, State', :distance => "4.0", :lat => 0, :lng => 0),
          mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => 'City, State', :distance => "4.2", :lat => 0, :lng => 0),
          Location::LocationHeader.new("City 2, State", :city, "5.2"),
          mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City 2, State', :distance => "5.0", :lat => 0, :lng => 0),
          mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => 'City 2, State', :distance => "5.2", :lat => 0, :lng => 0)
        ]

        db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

        Location.should_receive(:find).and_return(db_results)

        get :radius, :radius => "5", :address => '00000'

        assigns[:results].should == view_results
      end
    end
  end

  describe :find_params do
    it "should return a Hash" do
      controller.send(:find_params).should be_kind_of(Hash)
    end

    it "should contain origin, within, and order params" do
      controller.instance_eval do
        @address = :address
        @radius = :radius
      end

      controller.send(:find_params).should == {:origin => :address, :within => :radius, :order => :distance, :conditions => "hidden = false"}
    end

    it "should include the type_id if it is greater than 0" do
      controller.instance_eval {@type_id = 42}

      controller.send(:find_params)[:conditions].should == ['type_id = ? AND hidden = false', 42]
    end
  end

  describe :location_heading do
    before :each do
      @location = Location.new(:city => "City", :state => "State",
                               :zip_code => '00000', :country => "USA")
    end

    it "should display 'city, state' when city and state are present" do
      controller.send(:location_heading, @location).should == 'City, State'
    end

    it "should display 'city, state' when city and state are present" do
      controller.send(:location_heading, @location).should == 'City, State'
    end

    it "should display 'zip, state' when city is not present but zip is" do
      @location.city = nil
      controller.send(:location_heading, @location).should == '00000, State'
    end

    it "should display 'state, country' when city and zip are blank" do
      @location.city = @location.zip_code = nil
      controller.send(:location_heading, @location).should == 'State, USA'
    end

    it "should display 'country' when only country is present" do
      @location.city = @location.zip_code = @location.state = nil
      controller.send(:location_heading, @location).should == 'USA'
    end
  end

  def mock_location(options)
    options[:geocode_precision] ||= "city"

    options[:geocode_address] ||= case options[:geocode_precision]
                                  when "address"
                                    "123 Number St., City, State"
                                  when "city"
                                    "City, State"
                                  end

    components = options[:geocode_address].split(/,/)
    if components.size == 3  # address, city, state
      options[:street_address] ||= components[0].strip
      options[:city] ||= components[1].strip
      options[:state] ||= components[2].strip
    elsif components.size == 2  # city, state
      options[:city] ||= components[0].strip
      options[:state] ||= components[1].strip
    else
      raise "Invalid number of components in address"
    end

    options[:distance] ||= "0"

    mock_model(Location, options)
  end
end
