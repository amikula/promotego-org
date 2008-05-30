require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/show.html.erb" do
  include LocationsHelper
  
  before(:each) do
    @location = mock_model(Location, Location.valid_options)
    @location.stub!(:type).and_return(mock_model(Type, :name => "Foo"))

    assigns[:location] = @location
  end

  it "should render attributes in <p>" do
    render "/locations/show.html.erb"
    response.should have_text(/#{@location.name}/)
    response.should have_text(/#{@location.type.name}/)
    response.should have_text(/#{@location.type_id}/)
    response.should have_text(/#{@location.street_address}/)
    response.should have_text(/#{@location.city}/)
    response.should have_text(/#{@location.state}/)
    response.should have_text(/#{@location.zip_code}/)
    response.should have_text(/#{@location.phone_number}/)
    response.should have_text(/#{@location.lat}/)
    response.should have_text(/#{@location.lng}/)
  end
end

