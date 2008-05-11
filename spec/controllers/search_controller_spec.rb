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
end
