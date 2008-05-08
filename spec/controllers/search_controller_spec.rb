require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  it "should assign radii and types on radius_search" do
    get :radius
    assigns[:location]
    assigns[:radii]
    assigns[:types]
  end

  it "should perform a search if location is provided" do
    Location.should_receive(:find).with(:all, :origin => Location.new(:street_address => "169 N. Berkeley Ave.", :city => "Pasadena", :state => "CA", :zip_code => "91107"), :within => 5)
    get :radius, "location" => {:street_address => "169 N. Berkeley Ave.", :city => "Pasadena", :state => "CA", :zip_code => "91107"}, :radius => "5"
  end
end
