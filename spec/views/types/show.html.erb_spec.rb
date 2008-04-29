require File.dirname(__FILE__) + '/../../spec_helper'

describe "/types/show.html.erb" do
  include TypesHelper
  
  before(:each) do
    @type = mock_model(Type)
    @type.stub!(:name).and_return("MyString")

    assigns[:type] = @type
  end

  it "should render attributes in <p>" do
    render "/types/show.html.erb"
    response.should have_text(/MyString/)
  end
end

