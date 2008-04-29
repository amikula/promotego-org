require File.dirname(__FILE__) + '/../../spec_helper'

describe "/types/index.html.erb" do
  include TypesHelper
  
  before(:each) do
    type_98 = mock_model(Type)
    type_98.should_receive(:name).and_return("MyString")
    type_99 = mock_model(Type)
    type_99.should_receive(:name).and_return("MyString")

    assigns[:types] = [type_98, type_99]
  end

  it "should render list of types" do
    render "/types/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

