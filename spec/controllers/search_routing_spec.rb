require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  describe "route generation" do
    it "should map { :controller => 'search', :action => 'radius' } to /search/go-clubs/radius" do
      route_for(:controller => "search", :action => "radius").should == "/search/go-clubs/radius"
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'search', :action => 'radius' } from GET /search/radius" do
      params_from(:get, "/search/radius")[:controller].should == 'search'
      params_from(:get, "/search/radius")[:action].should == 'radius'
    end

    it "should generate params { :controller => 'search', :action => 'radius', :type => 'go-clubs' } from GET /search/go-clubs/radius" do
      params_from(:get, "/search/go-clubs/radius").should == {:controller => 'search', :action => 'radius', :type => 'go-clubs'}
    end
  end
end
