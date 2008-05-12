require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  before(:each) do
    @location = Location.new
  end

  it "should be valid" do
    @location.street_address="1600 Pennsylvania Ave."
    @location.city="Washington"
    @location.state="DC"
    @location.should be_valid
  end

  it "should combine components into a single address for geocoding" do
    @location.street_address="1600 Pennsylvania Ave."
    @location.city="Washington"
    @location.state="DC"
    @location.geocode_address.should == "1600 Pennsylvania Ave., Washington, DC"

    @location.errors.should be_empty
  end

  it "should report an error if at least city and state or zip code is not present" do
    @location.street_address="1600 Pennsylvania Ave."

    @location.geocode_address.should == nil
    @location.errors.should_not be_empty
  end

  it "should geocode with city and state or zip only, if street address is not present" do
    @location.city = "Washington"
    @location.state = "DC"

    @location.geocode_address.should == "Washington, DC"

    @location.errors.should be_empty
  end

  it "should set an error if geocode is not successful" do
    result = mock("geocode_result")
    result.stub!(:success).and_return(false)
    GeoKit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(result)

    @location.geocode.should == nil
    @location.errors.should_not be_empty
  end
end
