require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  before(:each) do
    @address = "169 N. Berkeley Ave., Pasadena, CA"
  end

  it "should assign radii and types on radius_search" do
    get :radius
    assigns[:location]
    assigns[:radii]
    assigns[:types]
  end

  it "should retrieve expected locations on search" do
    new_location(:name => "EarthLink Office",
                 :street_address => "2947 Bradley St.", :city => "Pasadena",
                 :state => "CA", :zip_code => "91107").geocode.save!
    new_location(:name => "White House",
                    :street_address => "1600 Pennsylvania Ave.",
                    :city => "Washington", :state => "DC").geocode.save!
    new_location(:name => "Mom and Dad's", :zip_code => "77072").geocode.save!

    get :radius, :address => @address, :radius => "5"

    assigns[:results].delete_if{|result| result.is_a?(Location::LocationHeader)}.size.should == 1
  end

  it "should find the closest result if no search results are present" do
    Location.should_receive(:find).with(:all, :origin => @address,
                            :within => 5, :order => :distance).and_return([])

    Location.should_receive(:find_closest).with(:origin => @address,
        :within => 100, :conditions => 'lat is not null and lng is not null')

    get :radius, :address => @address, :radius => "5"
  end

  describe "with type" do
    it "should search only go clubs when go_clubs type is present" do
      go_club = mock_model(Type, :name => "Go Club")
      Type.should_receive(:find_by_name).with("Go Club").and_return(go_club)

      Location.should_receive(:find).
        with(:all, :origin => @address, :within => 5,
             :conditions => ["type_id = ?", go_club.id], :order => :distance).
        and_return([mock_location(:geocode_precision => "address", :geocode_address => "City, State")])

      get :radius, :type => "go_clubs", :radius => "5", :address => @address
    end

    it 'should search only go clubs when go clubs is selected' do
      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:find).
        with(:all, :origin => @address, :within => 5,
             :conditions => ["type_id = ?", go_club.id], :order => :distance).and_return([mock_location(:geocode_precision => "address", :geocode_address => "123 Fake Lane, City, State")])

      get :radius, :type_id => go_club.id, :radius => "5",
        :address => @address
    end

    it 'should not raise error when type is invalid' do
      lambda{get :radius, :type => "bogus_type", :radius => "5", :address => @address}.should_not raise_error
    end

    it "should not filter by type id when type_id == 0" do
      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:find).
        with(:all, :origin => @address, :within => 5, :order => :distance).and_return([mock_location(:geocode_precision => "address")])

      get :radius, :type_id => 0, :radius => "5", :address => @address
    end

    it "should find the closest result if no search results are present" do
      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:find).
        with(:all, :origin => @address, :within => 5,
             :conditions => ["type_id = ?", go_club.id], :order => :distance).and_return([])

      Location.should_receive(:find_closest).
        with(:origin => @address, :within => 100,
             :conditions => ['lat is not null and lng is not null and type_id = ?', go_club.id]).
             and_return(:closest)

      get :radius, :type_id => go_club.id, :radius => "5",
        :address => @address

      assigns[:closest].should == :closest
    end
  end

  describe "should add location headings" do
    it "when results have no address" do
      view_results = [
        Location::LocationHeader.new("City, State", :city, "4.1"),
        mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "city", :geocode_address => "City, State", :distance => "4.1"),
        mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => "City, State", :distance => "4.1")
      ]

      db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

      Location.should_receive(:find).and_return(db_results)

      get :radius, :radius => "5", :address => '00000'

      assigns[:results].should == view_results
    end

    it "when results have addresses, use average distance" do
      view_results = [
        Location::LocationHeader.new("City, State", :city, "4.1"),
        mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City, State', :distance => "4.0"),
        mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "address", :geocode_address => '123 Sesame St., City, State', :distance => "4.2")
      ]

      db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

      Location.should_receive(:find).and_return(db_results)

      get :radius, :radius => "5", :address => '00000'

      assigns[:results].should == view_results
    end

    it "when some results have addresses and some don't" do
      view_results = [
        Location::LocationHeader.new("City, State", :city, "4.2"),
        mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City, State', :distance => "4.0"),
        mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => 'City, State', :distance => "4.2")
      ]

      db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

      Location.should_receive(:find).and_return(db_results)

      get :radius, :radius => "5", :address => '00000'

      assigns[:results].should == view_results
    end

    it "for each city" do
      view_results = [
        Location::LocationHeader.new("City, State", :city, "4.2"),
        mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City, State', :distance => "4.0"),
        mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => 'City, State', :distance => "4.2"),
        Location::LocationHeader.new("City 2, State", :city, "5.2"),
        mock_location(:type => :go_club, :name => "Location 1", :geocode_precision => "address", :geocode_address => '234 Sesame St., City 2, State', :distance => "5.0"),
        mock_location(:type => :go_club, :name => "Location 2", :geocode_precision => "city", :geocode_address => 'City 2, State', :distance => "5.2")
      ]

      db_results = view_results.clone.delete_if{|loc| loc.is_a? Location::LocationHeader}

      Location.should_receive(:find).and_return(db_results)

      get :radius, :radius => "5", :address => '00000'

      assigns[:results].should == view_results
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
