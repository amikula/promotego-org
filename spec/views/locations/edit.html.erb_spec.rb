require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/edit.html.erb" do
  include LocationsHelper
  
  before do
    @location = mock_model(Location, Location.valid_options)
    assigns[:location] = @location
    @types = [mock_model(Type, :name => "Type1"),
              mock_model(Type, :name => "Type2"),
              mock_model(Type, :name => "Type3")]
    assigns[:types] = @types
  end

  it "should render edit form" do
    render "/locations/edit.html.erb"

    response.should have_tag("form[action=#{location_path(@location)}][method=post]") do
      with_tag('input#location_name[name=?]', "location[name]")
      with_tag('select#location_type_id[name=?]', "location[type_id]") do
        @types.each do |type|
          with_tag('option[value=?]', type.id, type.name)
        end
      end
      with_tag('input#location_street_address[name=?]', "location[street_address]")
      with_tag('input#location_city[name=?]', "location[city]")
      with_tag('input#location_state[name=?]', "location[state]")
      with_tag('input#location_zip_code[name=?]', "location[zip_code]")
      with_tag('input#location_phone_number[name=?]', "location[phone_number]")
      with_tag('input#location_hours[name=?]', "location[hours]")
      with_tag('input#location_lat[name=?]', "location[lat]")
      with_tag('input#location_lng[name=?]', "location[lng]")
    end
  end

  it "should include users dropdown in edit form for administrators"
  it "should not include users dropdown in edit form for non-administrators"
end
