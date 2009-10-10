require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/new" do
  include UsersHelper

  before do
    @user = mock_model(User)
  end

  it "should render new form" do
    render "/users/new"

    response.should have_tag("form[action=/account][method=post]") do
      with_tag('input#user_login[name=?]', "user[login]")
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_password[name=?]', "user[password]")
      with_tag('input#user_password_confirmation[name=?]',
               "user[password_confirmation]")
      with_tag('input[type=?]', 'submit')
    end
  end
end
