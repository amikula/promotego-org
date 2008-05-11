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
  end
end
