require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/new.html.erb" do
  include LocationsHelper
  
  before(:each) do
    @location = mock_model(Location, Location.valid_options)
    @location.stub!(:new_record?).and_return(true)
    assigns[:location] = @location
  end

  it "should render new form" do
    render "/locations/new.html.erb"

    response.should have_tag("form[action=?][method=post]", locations_path) do
      with_tag("input#location_name[name=?]", "location[name]")
      with_tag("input#location_street_address[name=?]", "location[street_address]")
      with_tag("input#location_city[name=?]", "location[city]")
      with_tag("input#location_state[name=?]", "location[state]")
      with_tag("input#location_zip_code[name=?]", "location[zip_code]")
      with_tag("input#location_phone_number[name=?]", "location[phone_number]")
      with_tag("input#location_hours[name=?]", "location[hours]")
      with_tag("input#location_lat[name=?]", "location[lat]")
      with_tag("input#location_lng[name=?]", "location[lng]")
    end
  end
end


