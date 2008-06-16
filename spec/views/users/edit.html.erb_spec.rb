require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/edit.html.erb" do
  include UsersHelper
  
  before(:each) do
    @user = mock_model(User)
    @user.stub!(:has_role?).and_return(false)
    @controller.stub!(:current_user).and_return(@user)
  end

  it "should render edit form" do
    render "/users/edit.html.erb"

    response.should have_tag("form[action=/users][method=post]") do
      with_tag('input#user_login[name=?]', "user[login]")
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_password[name=?]', "user[password]")
      with_tag('input#user_password_confirmation[name=?]',
               "user[password_confirmation]")
      with_tag('input[type=?]', 'submit')
    end
  end

  it "should have a drop-down multi-selection list of roles for owners" do
    @user.should_receive(:has_role?).with(:owner).and_return(true)

    roles = [ mock_model(Role, :name => "owner"),
              mock_model(Role, :name => "super_user"),
              mock_model(Role, :name => "administrator") ]

    @user.should_receive(:roles).and_return(roles[1,2])

    assigns[:roles] = roles

    render "/users/edit.html.erb"

    response.should have_tag("form[action=/users][method=post]") do
      with_tag('select[multiple=multiple]') do
        roles.each do |role|
          with_tag("option[value=?]", role.id, role.name)
        end

        without_tag("option[value=?][selected=selected]", roles[0].id,
                    roles[0].name)
        with_tag("option[value=?][selected=selected]", roles[1].id,
                 roles[1].name)
        with_tag("option[value=?][selected=selected]", roles[2].id,
                 roles[2].name)
      end
    end
  end
end
