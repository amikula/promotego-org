require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/radius.html.erb" do
  include SearchHelper

  before(:each) do
    @types = [mock_model(Type, :name => "Foo"),
              mock_model(Type, :name => "Bar"),
              mock_model(Type, :name => "Baz")]
    assigns[:radii] = [1,2,3]
    assigns[:types] = @types
  end

  it 'should display type selector when type parameter is not present' do
    render "/search/radius.html.erb"

    response.should have_tag("select[name=type_id]")
  end

  it 'should not display type selector when type parameter is present' do
    params[:type] = :anything

    render "/search/radius.html.erb"

    response.should_not have_tag("select[name=type_id]")
  end

  it 'should have an action of /search/radius when type parameter is not present' do
    render '/search/radius.html.erb'

    response.should have_tag("form[action=/search/radius]")
  end

  it 'should have an action of /search/type/radius when type parameter is present' do
    params[:type] = "type"
    render '/search/radius.html.erb'

    response.should have_tag("form[action=/search/type/radius]")
  end

  it 'should select first type when @type_id matches first type' do
    check_type_selected(@types[0])
  end

  it 'should select second type when @type_id matches second type' do
    check_type_selected(@types[1])
  end

  it 'should select third type when @type_id matches third type' do
    check_type_selected(@types[2])
  end

  def check_type_selected(type)
    assigns[:type_id] = type.id
    render "/search/radius.html.erb"

    response.should have_tag("option[value=#{type.id}][selected=selected]")

    @types.reject{|x| x == type}.each do |check_type|
      response.should_not have_tag("option[value=#{check_type.id}][selected=selected]")
    end
  end
end


