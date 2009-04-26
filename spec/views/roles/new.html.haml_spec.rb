require File.dirname(__FILE__) + '/../../spec_helper'

describe "/roles/new" do
  include RolesHelper
  
  before(:each) do
    @role = mock_model(Role)
    @role.stub!(:new_record?).and_return(true)
    @role.stub!(:name).and_return("MyString")
    assigns[:role] = @role
  end

  it "should render new form" do
    render "/roles/new"
    
    response.should have_tag("form[action=?][method=post]", roles_path) do
      with_tag("input#role_name[name=?]", "role[name]")
    end
  end
end


