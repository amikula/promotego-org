require File.dirname(__FILE__) + '/../../spec_helper'

describe "/layouts/application" do
  def do_render
    params[:controller] = "no_controller"
    params[:action] = "no_action"

    render "/layouts/application"
  end

  it 'should have a link to Home' do
    do_render

    response.should have_tag("a[href=/]", "Home")
  end

  it 'should have a link to About' do
    do_render

    response.should have_tag("a[href=/about]", "About")
  end

  it 'should have a link to Home' do
    do_render

    response.should have_tag("a[href=/contact]", "Contact")
  end

  it 'should render @title' do
    assigns[:title] = "Test Title"

    do_render

    response.should have_tag("title", "Test Title")
  end

  it "should still have a title if @title is not assigned" do
    do_render

    response.should have_tag("title")
  end

  it "should have a link to log in if no user is logged in" do
    do_render

    response.should have_tag("a[href=?]", '/user_session/new', "Log in")
  end

  it "should display a register link if no user is logged in" do
    do_render

    response.should have_tag("a[href=?]", '/account/new', "Register")
  end

  it "should not display a login or register link if a user is logged in" do
    template.stub!(:current_user).and_return(mock_model(User, :login => "test_user_login", :active? => true))

    do_render

    response.should_not have_tag("a", "Register")
    response.should_not have_tag("a", "Log in")
  end

  it "should display the user name if a user is logged in" do
    template.stub!(:current_user).and_return(mock_model(User, :login => "test_user_login", :active? => true))

    do_render

    response.should have_text(/test_user_login/)
  end

  it "should display a logout link if a user is logged in" do
    template.stub!(:current_user).and_return(mock_model(User, :login => "test_user_login", :active? => true))

    do_render

    response.should have_tag("a[href=?]", '/user_session/destroy', "Log out")
  end
end


