require File.dirname(__FILE__) + '/../../spec_helper'

describe "/layouts/application.html.erb" do
  def do_render
    params[:controller] = "no_controller"
    params[:action] = "no_action"

    render "/layouts/application.html.erb"
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

  it "should have a link to log in" do
    do_render

    response.should have_tag("a[href=/session/new]", "Log in")
  end
end


