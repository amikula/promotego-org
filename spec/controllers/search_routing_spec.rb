require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  describe "route generation" do

    it "should map { :controller => 'search', :action => 'radius' } to /search/radius" do
      route_for(:controller => "search", :action => "radius").should == "/search/radius"
    end

    it "should map { :controller => 'search', :action => 'radius', :type => 'go_clubs' } to /search/go_clubs/radius" do
      route_for(:controller => "search", :action => "radius", :type => 'go_clubs').should == "/search/go_clubs/radius"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'search', action => 'radius' } from GET /search/radius" do
      params_from(:get, "/search/radius").should == {:controller => "search", :action => "radius"}
    end

    it "should generate params { :controller => 'search', action => 'radius', :type => go_club_object } from GET /search/go_clubs/radius" do
      params_from(:get, "/search/go_clubs/radius").should == {:controller => "search", :action => "radius", :type => "go_clubs"}
    end
  end
end
