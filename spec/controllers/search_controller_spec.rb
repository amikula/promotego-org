require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  it "should assign radii and types on radius_search" do
    get :radius
    assigns[:location]
    assigns[:radii]
    assigns[:types]
  end

  it "should perform a search if location is provided" do
    params = {"street_address" => "169 N. Berkeley Ave.", "city" => "Pasadena", "state" => "CA", "zip_code" => "91107"}
    origin = Location.new(params)
    Location.should_receive(:new).with(params).and_return(origin)
    Location.should_receive(:find).with(:all, :origin => origin, :within => 5).and_return([])
    get :radius, "location" => params, :radius => "5"
  end

  it "should retrieve expected locations on search" do
    new_location(:name => "EarthLink Office", :street_address => "2947 Bradley St.", :city => "Pasadena", :state => "CA", :zip_code => "91107").geocode.save!
    create_location(:name => "White House", :street_address => "1600 Pennsylvania Ave.", :city => "Washington", :state => "DC").geocode.save!
    create_location(:name => "Mom and Dad's", :zip_code => "77072").geocode.save!

    params = {"street_address" => "169 N. Berkeley Ave.", "city" => "Pasadena", "state" => "CA", "zip_code" => "91107"}
    get :radius, "location" => params, :radius => "5"

    assigns[:results].size.should == 1
  end

  it "should set a message if no search results are present" do
    params = {"street_address" => "169 N. Berkeley Ave.", "city" => "Pasadena", "state" => "CA", "zip_code" => "91107"}
    origin = Location.new(params)
    Location.should_receive(:new).with(params).and_return(origin)
    Location.should_receive(:find).with(:all, :origin => origin, :within => 5).and_return([])

    # stub out sweep so we can read flash.now
    @controller.instance_eval{flash.stub!(:sweep)}

    get :radius, "location" => params, :radius => "5"

    flash.now[:error].should == "No locations matched your search"
  end
end
