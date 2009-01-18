require File.dirname(__FILE__) + '/../../spec_helper'

describe "/locations/edit" do
  include LocationsHelper
  
  before do
    @user = mock_model(User)
    @user.stub!(:has_role?).and_return(false)
    @controller.stub!(:current_user).and_return(@user)

    @location = mock_model(Location, Location.valid_options)
    assigns[:location] = @location
    @types = [mock_model(Type, :name => "Type1"),
              mock_model(Type, :name => "Type2"),
              mock_model(Type, :name => "Type3")]
    assigns[:types] = @types
  end

  it "should render edit form" do
    render "/locations/edit"

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
      with_tag('input#location_hours[name=?]', "location[hours]")
      with_tag('textarea#location_description[name=?]', "location[description]")
      with_tag('input#location_url[name=?]', "location[url]")
    end
  end

  describe "users field" do
    it "should be included in edit form for super-users" do
      @user.should_receive(:has_role?).with(:administrator).and_return(true)

      render "/locations/edit"

      response.should have_tag("form[action=#{location_path(@location)}][method=post]") do
        with_tag('input#user_login[name=?]', 'user[login]')
      end
    end

    it "should not be included in edit form for non-super-users" do
      @user.should_receive(:has_role?).with(:administrator).and_return(false)

      render "/locations/edit"

      response.should have_tag("form[action=#{location_path(@location)}][method=post]") do
        without_tag('input#user_login[name=?]', 'user[login]')
      end
    end
  end
end
