require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/new" do
  include UsersHelper
  
  before do
    @user = mock_model(User)
#    @user.stub!(:has_role?).and_return(false)
#    @controller.stub!(:current_user).and_return(@user)
#
#    @location = mock_model(Location, Location.valid_options)
#    assigns[:location] = @location
#    @types = [mock_model(Type, :name => "Type1"),
#              mock_model(Type, :name => "Type2"),
#              mock_model(Type, :name => "Type3")]
#    assigns[:types] = @types
  end

  it "should render new form" do
    render "/users/new"

    response.should have_tag("form[action=/users][method=post]") do
      with_tag('input#user_login[name=?]', "user[login]")
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_password[name=?]', "user[password]")
      with_tag('input#user_password_confirmation[name=?]',
               "user[password_confirmation]")
      with_tag('input[type=?]', 'submit')
    end
  end
end
