require File.dirname(__FILE__) + '/../../spec_helper'

describe "/roles/show.html.erb" do
  include RolesHelper
  
  before(:each) do
    @role = mock_model(Role)
    @role.stub!(:name).and_return("MyString")

    assigns[:role] = @role
  end

  it "should render attributes in <p>" do
    render "/roles/show.html.erb"
    response.should have_text(/MyString/)
  end
end

