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
    do_render

    response.should have_tag("select[name=type_id]")
  end

  it 'should not display type selector when type parameter is present' do
    params[:type] = :anything

    do_render

    response.should_not have_tag("select[name=type_id]")
  end

  it 'should have an action of /search/radius when type parameter is not present' do
    do_render

    response.should have_tag("form[action=/search/radius]")
  end

  it 'should have an action of /search/type/radius when type parameter is present' do
    params[:type] = "type"
    do_render

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

  describe 'with results' do
    before(:each) do
      @results = [mock_model(Location, :name => "The Club", :geocode_address => "The Address", :distance => 5, :precision => :precision, :type => :type, :slug => 'the-club')]
      assigns[:results] = @results
    end

    it 'should link names of results to their display pages' do
      do_render

      response.should have_tag("a[href=?]", "/locations/#{@results[0].slug}", @results[0].name)
    end
  end

  describe 'with location headings' do
    before(:each) do
      @results = [
        Location::LocationHeader.new("City, State", :city, "5.1"),
        mock_model(Location, :name => "Club 1",
                   :geocode_address => "Club Address 1", :distance => 5.1,
                   :type => :some_type, :precision => :city, :slug => 'club-1'),
        mock_model(Location, :name => "Club 2",
                   :geocode_address => "Club Address 2", :distance => 5.1,
                   :type => :some_type, :precision => :city, :slug => 'club-2'),
        Location::LocationHeader.new("City, State 2", :city, "5.8"),
        mock_model(Location, :name => "Club 3",
                   :geocode_address => "Club Address 3", :distance => 5.8,
                   :type => :some_type, :precision => :city, :slug => 'club-3'),
        Location::LocationHeader.new("City, State 3", :city, "5.9"),
        mock_model(Location, :name => "Club 4",
                   :geocode_address => "Club Address 4", :distance => 5.9,
                   :type => :some_type, :precision => :city, :slug => 'club-4')
      ]
      assigns[:results] = @results
    end

    it 'should contain location headings' do
      do_render

      response.should have_tag("tr[class=?]", "location_header") do
        with_tag("td", "City, State")
        with_tag("td", "5.1")
      end
    end

    it 'should not list address for clubs under location headings' do
      do_render

      response.should have_tag("tr[class=?]", "location") do
        with_tag("td", "Club 1")
        without_tag("td", "Club Address 1")
        without_tag("td", "5.1")
      end
    end

    it 'should handle location heading when already displaying one heading' do
      do_render

      response.should have_tag("tr[class=?]", "location_header") do
        with_tag("td", "City, State 2")
        with_tag("td", "5.8")
      end

      response.should have_tag("tr[class=?]", "location") do
        with_tag("td", "Club 3")
        without_tag("td", "Club Address 3")
        without_tag("td", "5.8")
      end

      response.should have_tag("tr[class=?]", "location_header") do
        with_tag("td", "City, State 3")
        with_tag("td", "5.9")
      end

      response.should have_tag("tr[class=?]", "location") do
        with_tag("td", "Club 4")
        without_tag("td", "Club Address 4")
        without_tag("td", "5.9")
      end
    end
  end

  def do_render
    render '/search/radius.html.erb'
  end

  def check_type_selected(type)
    assigns[:type_id] = type.id
    do_render

    response.should have_tag("option[value=#{type.id}][selected=selected]")

    @types.reject{|x| x == type}.each do |check_type|
      response.should_not have_tag("option[value=#{check_type.id}][selected=selected]")
    end
  end
end


