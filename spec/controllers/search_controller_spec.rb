require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  before(:each) do
    @params = {"street_address" => "169 N. Berkeley Ave.", "city" => "Pasadena",
              "state" => "CA", "zip_code" => "91107"}
  end

  it "should assign radii and types on radius_search" do
    get :radius
    assigns[:location]
    assigns[:radii]
    assigns[:types]
  end

  it "should perform a search if location is provided" do
    origin = Location.new(@params)
    Location.should_receive(:new).with(@params).and_return(origin)
    Location.should_receive(:find).with(:all, :origin => origin, :within => 5).
      and_return([])
    get :radius, "location" => @params, :radius => "5"
  end

  it "should retrieve expected locations on search" do
    new_location(:name => "EarthLink Office",
                 :street_address => "2947 Bradley St.", :city => "Pasadena",
                 :state => "CA", :zip_code => "91107").geocode.save!
    new_location(:name => "White House",
                    :street_address => "1600 Pennsylvania Ave.",
                    :city => "Washington", :state => "DC").geocode.save!
    new_location(:name => "Mom and Dad's", :zip_code => "77072").geocode.save!

    get :radius, "location" => @params, :radius => "5"

    assigns[:results].size.should == 1
  end

  it "should set a message if no search results are present" do
    origin = Location.new(@params)
    Location.should_receive(:new).with(@params).and_return(origin)
    Location.should_receive(:find).with(:all, :origin => origin, :within => 5).
      and_return([])

    # stub out sweep so we can read flash.now
    @controller.instance_eval{flash.stub!(:sweep)}

    get :radius, "location" => @params, :radius => "5"

    flash.now[:error].should == "No locations matched your search"
  end

  describe "with type" do
    it "should search only go clubs when go_clubs type is present" do
      origin = Location.new(@params)

      go_club = mock_model(Type, :name => "Go Club")
      Type.should_receive(:find_by_name).with("Go Club").and_return(go_club)

      Location.should_receive(:new).with(@params).and_return(origin)
      Location.should_receive(:find).with(:all, :origin => origin, :within => 5,
                                          :conditions =>
                                  ["type_id = ?", go_club.id]).and_return([])

      get :radius, "type" => "go_clubs", :radius => "5", "location" => @params
    end

    it 'should search only go clubs when go clubs is selected' do
      origin = Location.new(@params)

      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:new).with(@params).and_return(origin)
      Location.should_receive(:find).
        with(:all, :origin => origin, :within => 5,
             :conditions => ["type_id = ?", go_club.id]).and_return([])

      get :radius, "type_id" => go_club.id, :radius => "5",
        "location" => @params
    end

    it 'should redirect with a message when type is invalid' do
      get :radius, "type" => "bogus_type", :radius => "5", "location" => @params

      flash[:error].should == "Type 'bogus_type' is invalid."
      response.should redirect_to(:action => "radius")
    end

    it "should not filter by type id when type_id == 0" do
      origin = Location.new(@params)

      go_club = mock_model(Type, :name => "Go Club")

      Location.should_receive(:new).with(@params).and_return(origin)
      Location.should_receive(:find).
        with(:all, :origin => origin, :within => 5).and_return([])

      get :radius, "type_id" => 0, :radius => "5",
        "location" => @params
    end
  end
end
