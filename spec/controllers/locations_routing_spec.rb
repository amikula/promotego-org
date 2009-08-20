require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsController do
  describe "route generation" do
    it "should map { :controller => 'locations', :action => 'index' } to /locations" do
      route_for(:controller => "locations", :action => "index").should == "/locations"
    end

    it "should map { :controller => 'locations', :action => 'new' } to /locations/new" do
      route_for(:controller => "locations", :action => "new").should == "/locations/new"
    end

    it "should map { :controller => 'locations', :action => 'show', :id => 1 } to /locations/1" do
      route_for(:controller => 'locations', :action => 'show', :id => '1').should == {:path => '/locations/1', :method => 'get'}
    end

    it "should map { :controller => 'locations', :action => 'edit', :id => 1 } to /locations/1/edit" do
      route_for(:controller => "locations", :action => "edit", :id => '1').should == {:path => "/locations/1/edit", :method => 'get'}
    end

    it "should map { :controller => 'locations', :action => 'update', :id => 1} to /locations/1" do
      route_for(:controller => 'locations', :action => 'update', :id => '1').should == {:path => '/locations/1', :method => 'put'}
    end

    it "should map { :controller => 'locations', :action => 'destroy', :id => 1} to /locations/1" do
      route_for(:controller => 'locations', :action => 'destroy', :id => '1').should == {:path => '/locations/1', :method => 'delete'}
    end

    it "maps to /go-clubs/Country/State when country and state are provided and action is index" do
      route_for(:controller => 'locations', :action => 'index', :country => 'Country', :state => 'State', :type => 'go-clubs').
        should == '/go-clubs/Country/State'
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'locations', action => 'index' } from GET /locations" do
      params_from(:get, "/locations").should == {:controller => "locations", :action => "index"}
    end

    it "should generate params { :controller => 'locations', action => 'new' } from GET /locations/new" do
      params_from(:get, "/locations/new").should == {:controller => "locations", :action => "new"}
    end

    it "should generate params { :controller => 'locations', action => 'create' } from POST /locations" do
      params_from(:post, "/locations").should == {:controller => "locations", :action => "create"}
    end

    it "should generate params { :controller => 'locations', action => 'show', id => '1' } from GET /locations/1" do
      params_from(:get, "/locations/1").should == {:controller => "locations", :action => "show", :id => "1"}
    end

    it "should generate params { :controller => 'locations', action => 'edit', id => '1' } from GET /locations/1;edit" do
      params_from(:get, "/locations/1/edit").should == {:controller => "locations", :action => "edit", :id => "1"}
    end

    it "should generate params { :controller => 'locations', action => 'update', id => '1' } from PUT /locations/1" do
      params_from(:put, "/locations/1").should == {:controller => "locations", :action => "update", :id => "1"}
    end

    it "should generate params { :controller => 'locations', action => 'destroy', id => '1' } from DELETE /locations/1" do
      params_from(:delete, "/locations/1").should == {:controller => "locations", :action => "destroy", :id => "1"}
    end

    it "generates params { :controller => 'locations', :action => 'index', :state => 'State', :country => 'Country' } from GET /go-clubs/Country/State" do
      params_from(:get, "/go-clubs/Country/State").should == {:controller => "locations", :action => "index", :country => 'Country', :state => 'State', :type => 'go-clubs'}
    end

    it "generates params { :controller => 'locations', :action => 'index', :state => 'State', :country => 'Country' } from GET /go_clubs/Country/State" do
      params_from(:get, "/go_clubs/Country/State").should == {:controller => "locations", :action => "index", :country => 'Country', :state => 'State', :type => 'go_clubs'}
    end
  end
end
