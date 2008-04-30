require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/edit.html.erb" do
  include LocationsHelper
  
  before do
    @location = mock_model(Location)
    @location.stub!(:name).and_return("MyString")
    @location.stub!(:type_id).and_return("1")
    @location.stub!(:street_address).and_return("MyString")
    @location.stub!(:city).and_return("MyString")
    @location.stub!(:state).and_return("MyString")
    @location.stub!(:zip_code).and_return("MyString")
    @location.stub!(:phone_number).and_return("MyString")
    @location.stub!(:hours).and_return("MyString")
    assigns[:location] = @location
  end

  it "should render edit form" do
    render "/locations/edit.html.erb"
    
    response.should have_tag("form[action=#{location_path(@location)}][method=post]") do
      with_tag('input#location_name[name=?]', "location[name]")
      with_tag('input#location_street_address[name=?]', "location[street_address]")
      with_tag('input#location_city[name=?]', "location[city]")
      with_tag('input#location_state[name=?]', "location[state]")
      with_tag('input#location_zip_code[name=?]', "location[zip_code]")
      with_tag('input#location_phone_number[name=?]', "location[phone_number]")
      with_tag('input#location_hours[name=?]', "location[hours]")
    end
  end
end


