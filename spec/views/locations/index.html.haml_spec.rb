require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/index" do
  include LocationsHelper

  before(:each) do
    @location_98 = mock_model(Location)
    @location_98.stub!(:name).any_number_of_times.and_return("Location1 Name")
    @type1 = mock_model(Type, :name => "Type1 Name")
    @location_98.stub!(:city).and_return("city1")
    @location_98.stub!(:state).and_return("ST1")
    @location_98.stub!(:street_address).at_least(:once).and_return("StreetAddress1")
    @location_99 = mock_model(Location)
    @location_99.stub!(:name).any_number_of_times.and_return("Location2 Name")
    @type2 = mock_model(Type, :name => "Type2 Name")
    @location_99.stub!(:city).and_return("city2")
    @location_99.stub!(:state).and_return("ST2")
    @location_99.stub!(:street_address).at_least(:once).and_return("StreetAddress2")

    @user = mock_model(User)
    @other_user = mock_model(User)

    @location_98.stub!(:user).and_return(@user)
    @location_99.stub!(:user).and_return(@other_user)

    @controller.stub!(:current_user).and_return(@user)

    assigns[:locations] = [@location_98, @location_99]
    assigns[:fields] = [:city, :state, :country]
  end

  it "renders a list of locations" do
    render "/locations/index"
    response.should have_tag("tr>td", "Location1 Name")
    response.should have_tag("tr>td", "Location2 Name")
    response.should have_tag("tr>td", "city1")
    response.should have_tag("tr>td", "city2")
    response.should have_tag("tr>td", "ST1")
    response.should have_tag("tr>td", "ST2")
  end

  it "renders other users' locations with class other_users" do
    render "/locations/index"

    response.should have_tag("tr>td", "Location1 Name")

    response.should have_tag("tr.other_users") do
      with_tag("td", "Location2 Name")
    end
  end

  it "links the name of the location to its display page" do
    render "/locations/index"

    response.should have_tag("a[href=/locations/#{@location_98.id}]", @location_98.name)
    response.should have_tag("a[href=/locations/#{@location_99.id}]", @location_99.name)
  end

  it 'does not throw an error on a state page when a city is nil' do
    assigns[:locations] = [mock_model(Location, :city => nil), mock_model(Location, :city => 'A City')]
    params[:state] = 'Bogus'
    template.stub!(:render).with(hash_including(:partial => 'location_line'))

    lambda{render '/locations/index'}.should_not raise_error
  end

  it 'does not throw an error on a country page when a state is nil' do
    assigns[:locations] = [mock_model(Location, :city => 'A City', :state => 'A State'),
                           mock_model(Location, :city => 'A City', :state => nil)]
    assigns[:country]   = 'US'

    template.stub!(:render).with(hash_including(:partial => 'location_line'))

    lambda{render '/locations/index'}.should_not raise_error
  end

  it 'does not throw an error on a country page when a city is nil' do
    assigns[:locations] = [mock_model(Location, :city => 'A City', :state => 'A State'),
                           mock_model(Location, :city => 'B City', :state => 'B State'),
                           mock_model(Location, :city =>      nil, :state => 'B State')]
    assigns[:country]   = 'US'

    template.stub!(:render).with(hash_including(:partial => 'location_line'))

    lambda{render '/locations/index'}.should_not raise_error
  end
end
