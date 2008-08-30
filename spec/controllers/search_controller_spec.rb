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

  it "should perform a search if location is provided" do
    Location.should_receive(:find).
      with(:all, :origin => @address, :within => 5, :order => :distance).and_return([:result])
    get :radius, :address => @address, :radius => "5"
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

    assigns[:results].size.should == 1
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
        and_return([:result])

      get :radius, :type => "go_clubs", :radius => "5", :address => @address
    end

    it 'should search only go clubs when go clubs is selected' do
      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:find).
        with(:all, :origin => @address, :within => 5,
             :conditions => ["type_id = ?", go_club.id], :order => :distance).and_return([:result])

      get :radius, :type_id => go_club.id, :radius => "5",
        :address => @address
    end

    it 'should redirect with a message when type is invalid' do
      get :radius, :type => "bogus_type", :radius => "5", :address => @address

      flash[:error].should == "Type 'bogus_type' is invalid."
      response.should redirect_to(:action => "radius")
    end

    it "should not filter by type id when type_id == 0" do
      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:find).
        with(:all, :origin => @address, :within => 5, :order => :distance).and_return([:result])

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
end
