require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/index.html.erb" do
  include LocationsHelper
  
  before(:each) do
    location_98 = mock_model(Location)
    location_98.should_receive(:name).and_return("MyString")
    location_98.should_receive(:type_id).and_return("1")
    location_98.should_receive(:street_address).and_return("MyString")
    location_98.should_receive(:city).and_return("MyString")
    location_98.should_receive(:state).and_return("MyString")
    location_98.should_receive(:zip_code).and_return("MyString")
    location_98.should_receive(:phone_number).and_return("MyString")
    location_98.should_receive(:hours).and_return("MyString")
    location_98.should_receive(:lat).and_return("MyString")
    location_98.should_receive(:lng).and_return("MyString")
    location_99 = mock_model(Location)
    location_99.should_receive(:name).and_return("MyString")
    location_99.should_receive(:type_id).and_return("1")
    location_99.should_receive(:street_address).and_return("MyString")
    location_99.should_receive(:city).and_return("MyString")
    location_99.should_receive(:state).and_return("MyString")
    location_99.should_receive(:zip_code).and_return("MyString")
    location_99.should_receive(:phone_number).and_return("MyString")
    location_99.should_receive(:hours).and_return("MyString")
    location_99.should_receive(:lat).and_return("MyString")
    location_99.should_receive(:lng).and_return("MyString")

    assigns[:locations] = [location_98, location_99]
  end

  it "should render list of locations" do
    render "/locations/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end

