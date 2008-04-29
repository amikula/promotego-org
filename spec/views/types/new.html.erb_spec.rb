require File.dirname(__FILE__) + '/../../spec_helper'

describe "/types/new.html.erb" do
  include TypesHelper
  
  before(:each) do
    @type = mock_model(Type)
    @type.stub!(:new_record?).and_return(true)
    @type.stub!(:name).and_return("MyString")
    assigns[:type] = @type
  end

  it "should render new form" do
    render "/types/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", types_path) do
      with_tag("input#type_name[name=?]", "type[name]")
    end
  end
end


