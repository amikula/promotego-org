require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/show" do
  include LocationsHelper
  
  before(:each) do
    @location = mock_model(Location, Location.valid_options)
    @location.stub!(:city_state_zip).and_return('City, State 00000')
    @location.stub!(:type).and_return(mock_model(Type, :name => "Foo"))
    @owner = mock_model(User, :login => "owner", :has_role? => false)
    @normal = mock_model(User, :login => "normal", :has_role? => false)
    @location.stub!(:user).and_return(@owner)
    @location.stub!(:is_aga?).and_return(true)

    @administrator = mock_model(User, :login => "administrator")
    @administrator.stub!(:has_role?).with(:administrator).and_return(true)

    assigns[:location] = @location
  end

  it "should render attributes in <p>" do
    render "/locations/show"
    response.should have_text(/#{@location.name}/)
    response.should have_text(/#{@location.type.name}/)
    response.should have_text(/#{@location.street_address}/)
    response.should have_text(/#{@location.city_state_zip}/)
    response.should have_text(/#{@location.country}/)
    response.should have_text(/#{@location.description}/)
  end

  describe "edit and destroy links" do
    describe "don't display" do
      it "when no user is logged in and no user owns the record" do
        template.stub!(:current_user).and_return(nil)
        @location.stub!(:user).and_return(nil)
        render "/locations/show"
        response.should_not have_tag('a', 'Edit')
        response.should_not have_tag('a', 'Destroy')
      end

      it "when no user is logged in" do
        template.stub!(:current_user).and_return(nil)
        render "/locations/show"
        response.should_not have_tag('a', 'Edit')
        response.should_not have_tag('a', 'Destroy')
      end

      it "when normal user is logged in" do
        template.stub!(:current_user).and_return(@normal)
        render "/locations/show"
        response.should_not have_tag('a', 'Edit')
        response.should_not have_tag('a', 'Destroy')
      end
    end

    describe "display" do
      it "when location's owner is logged in" do
        template.stub!(:current_user).and_return(@owner)
        render "/locations/show"
        response.should have_tag('a', 'Edit')
        response.should have_tag('a', 'Destroy')
      end

      it "when administrator is logged in" do
        template.stub!(:current_user).and_return(@administrator)
        render "/locations/show"
        response.should have_tag('a', 'Edit')
        response.should have_tag('a', 'Destroy')
      end
    end
  end

  describe "with nil contacts" do
    it "shouldn't break with nil contacts" do
      @location.stub!(:contacts).and_return(nil)
      lambda{render "/locations/show"}.should_not raise_error
    end
  end
end

