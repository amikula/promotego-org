require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/new" do
  include LocationsHelper

  before(:each) do
    @user = mock_model(User)
    @user.stub!(:has_role?).and_return(false)
    @controller.stub!(:current_user).and_return(@user)

    @location = mock_model(Location, Location.valid_options)
    @location.stub!(:new_record?).and_return(true)
    assigns[:location] = @location
  end

  it "should render new form" do
    render "/locations/new"

    response.should have_tag("form[action=?][method=post]", locations_path) do
      with_tag("input#location_name[name=?]", "location[name]")
      with_tag("input#location_street_address[name=?]", "location[street_address]")
      with_tag("input#location_city[name=?]", "location[city]")
      with_tag("input#location_state[name=?]", "location[state]")
      with_tag("input#location_zip_code[name=?]", "location[zip_code]")
      with_tag("input#location_hours[name=?]", "location[hours]")
      with_tag("textarea#location_description[name=?]", "location[description]")
      with_tag("input#location_url[name=?]", "location[url]")
    end
  end
end


