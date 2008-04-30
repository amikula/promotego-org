require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/show.html.erb" do
  include LocationsHelper
  
  before(:each) do
    @location = mock_model(Location)
    @location.stub!(:name).and_return("MyString")
    @location.stub!(:type_id).and_return("1")
    @location.stub!(:address).and_return("MyString")
    @location.stub!(:city).and_return("MyString")
    @location.stub!(:state).and_return("MyString")
    @location.stub!(:zip_code).and_return("MyString")
    @location.stub!(:phone_number).and_return("MyString")
    @location.stub!(:hours).and_return("MyString")

    assigns[:location] = @location
  end

  it "should render attributes in <p>" do
    render "/locations/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

