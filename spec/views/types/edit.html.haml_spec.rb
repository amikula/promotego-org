require File.dirname(__FILE__) + '/../../spec_helper'

describe "/types/edit" do
  include TypesHelper
  
  before do
    @type = mock_model(Type)
    @type.stub!(:name).and_return("MyString")
    assigns[:type] = @type
  end

  it "should render edit form" do
    render "/types/edit"
    
    response.should have_tag("form[action=#{type_path(@type)}][method=post]") do
      with_tag('input#type_name[name=?]', "type[name]")
    end
  end
end


