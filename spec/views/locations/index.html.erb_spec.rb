require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/index.html.erb" do
  include LocationsHelper
  
  before(:each) do
    @location_98 = mock_model(Location)
    @location_98.should_receive(:name).any_number_of_times.and_return("Location1 Name")
    @location_98.should_receive(:type_id).and_return("123")
    @location_98.should_receive(:street_address).and_return("street_address 1")
    @location_98.should_receive(:city).and_return("city1")
    @location_98.should_receive(:state).and_return("ST1")
    @location_98.should_receive(:zip_code).and_return("zip1")
    @location_98.should_receive(:phone_number).and_return("phnum1")
    @location_98.should_receive(:hours).and_return("hours1")
    @location_99 = mock_model(Location)
    @location_99.should_receive(:name).any_number_of_times.and_return("Location2 Name")
    @location_99.should_receive(:type_id).and_return("456")
    @location_99.should_receive(:street_address).and_return("street_address 2")
    @location_99.should_receive(:city).and_return("city2")
    @location_99.should_receive(:state).and_return("ST2")
    @location_99.should_receive(:zip_code).and_return("zip2")
    @location_99.should_receive(:phone_number).and_return("phnum2")
    @location_99.should_receive(:hours).and_return("hours2")

    @user = mock_model(User)
    @other_user = mock_model(User)

    @location_98.should_receive(:user).and_return(@user)
    @location_99.should_receive(:user).and_return(@other_user)

    @controller.stub!(:current_user).and_return(@user)

    assigns[:locations] = [@location_98, @location_99]
  end

  it "should render list of locations" do
    render "/locations/index.html.erb"
    response.should have_tag("tr>td", "Location1 Name")
    response.should have_tag("tr>td", "Location2 Name")
    response.should have_tag("tr>td", "123")
    response.should have_tag("tr>td", "456")
    response.should have_tag("tr>td", "street_address 1")
    response.should have_tag("tr>td", "street_address 2")
    response.should have_tag("tr>td", "city1")
    response.should have_tag("tr>td", "city2")
    response.should have_tag("tr>td", "ST1")
    response.should have_tag("tr>td", "ST2")
    response.should have_tag("tr>td", "zip1")
    response.should have_tag("tr>td", "zip2")
    response.should have_tag("tr>td", "phnum1")
    response.should have_tag("tr>td", "phnum2")
    response.should have_tag("tr>td", "hours1")
    response.should have_tag("tr>td", "hours2")
  end

  it "should render other users' locations with class other_users" do
    render "/locations/index.html.erb"

    response.should have_tag("tr>td", "Location1 Name")

    response.should have_tag("tr.other_users") do
      with_tag("td", "Location2 Name")
    end
  end

  it "should link the name of the location to its display page" do
    render "/locations/index.html.erb"

    response.should have_tag("a[href=/locations/#{@location_98.id}]", @location_98.name)
    response.should have_tag("a[href=/locations/#{@location_99.id}]", @location_99.name)
  end
end

