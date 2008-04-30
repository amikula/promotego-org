require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  before(:each) do
    @location = Location.new
  end

  it "should be valid" do
    @location.address="1600 Pennsylvania Ave."
    @location.city="Washington"
    @location.state="DC"
    @location.should be_valid
  end
end
