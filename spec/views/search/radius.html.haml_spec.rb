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
                             :slug => 'the-club', :city => 'City', :state => 'State')]
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
        mock_model(Location, :name => "Club 1", :street_address => "Street Address 1", :distance => 5.1,
                   :geocode_precision => :address, :slug => 'club-1', :city => 'City1', :state => 'State'),
        mock_model(Location, :name => "Club 2", :street_address => "Street Address 2", :distance => 5.2,
                   :geocode_precision => :city, :slug => 'club-2', :city => 'City1', :state => 'State'),
        mock_model(Location, :name => "Club 3", :street_address => "Street Address 3", :distance => 5.8,
                   :geocode_precision => :address, :slug => 'club-3', :city => 'City1', :state => 'State'),
        mock_model(Location, :name => "Club 4", :street_address => "Street Address 4", :distance => 5.9,
                   :geocode_precision => :address, :slug => 'club-4', :city => 'City2', :state => 'State')
      ]
      assigns[:results] = @results
    end

    it 'should contain location headings' do
      do_render

      response.should have_tag("tr[class=?]", "location_header") do
        with_tag("td", "City1, State")
        with_tag("td", "5.2")
      end
    end

    describe 'with auto-expanded results' do
      before(:each) do
        assigns[:closest] = true
      end

      it 'displays special text when results have been expanded outside the original search area' do
        results = [:result]
        assigns[:results] = results

        template.stub!(:sort_locations_by_distance)

        do_render

        response.should have_tag('h1', %r{No Match})
        response.should have_tag('p', %r{here is the closest match})
      end
    end
  end

  def do_render
    render '/search/radius'
  end
end


