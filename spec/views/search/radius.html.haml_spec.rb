require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/radius" do
  include SearchHelper

  before(:each) do
    assigns[:radii] = [1,2,3]
  end

  it 'should have an action of /search/go-clubs/radius' do
    do_render

    response.should have_tag("form[action=/search/go-clubs/radius]")
  end

  describe 'with results' do
    before(:each) do
      @results = [mock_model(Location, :name => "The Club", :geocode_address => "Geocode Address",
                             :street_address => "Street Address", :distance => 5, :geocode_precision => :precision,
                             :slug => 'the-club')]
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
        mock_model(Location, :name => "Club 1", :street_address => "Street Address 1", :distance => 5.1,
                   :geocode_precision => :city, :slug => 'club-1'),
        mock_model(Location, :name => "Club 2", :street_address => "Street Address 2", :distance => 5.1,
                   :geocode_precision => :city, :slug => 'club-2'),
        Location::LocationHeader.new("City, State 2", :city, "5.8"),
        mock_model(Location, :name => "Club 3", :street_address => "Street Address 3", :distance => 5.8,
                   :geocode_precision => :city, :slug => 'club-3'),
        Location::LocationHeader.new("City, State 3", :city, "5.9"),
        mock_model(Location, :name => "Club 4", :street_address => "Street Address 4", :distance => 5.9,
                   :geocode_precision => :city, :slug => 'club-4')
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
    render '/search/radius'
  end
end


