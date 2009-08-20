require File.dirname(__FILE__) + '/../spec_helper'

describe RolesController do
  describe "route generation" do

    it "should map { :controller => 'roles', :action => 'index' } to /roles" do
      route_for(:controller => "roles", :action => "index").should == "/roles"
    end

    it "should map { :controller => 'roles', :action => 'new' } to /roles/new" do
      route_for(:controller => "roles", :action => "new").should == "/roles/new"
    end

    it "should map { :controller => 'roles', :action => 'show', :id => 1 } to /roles/1" do
      route_for(:controller => "roles", :action => "show", :id => '1').should == "/roles/1"
    end

    it "should map { :controller => 'roles', :action => 'edit', :id => 1 } to /roles/1/edit" do
      route_for(:controller => "roles", :action => "edit", :id => '1').should == "/roles/1/edit"
    end

    it "should map { :controller => 'roles', :action => 'update', :id => 1} to /roles/1" do
      route_for(:controller => 'roles', :action => 'update', :id => '1').should == {:path => '/roles/1', :method => 'put'}
    end

    it "should map { :controller => 'roles', :action => 'destroy', :id => '1'} to /roles/1" do
      route_for(:controller => 'roles', :action => 'destroy', :id => '1').should == {:path => '/roles/1', :method => 'delete'}
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'roles', action => 'index' } from GET /roles" do
      params_from(:get, "/roles").should == {:controller => "roles", :action => "index"}
    end

    it "should generate params { :controller => 'roles', action => 'new' } from GET /roles/new" do
      params_from(:get, "/roles/new").should == {:controller => "roles", :action => "new"}
    end

    it "should generate params { :controller => 'roles', action => 'create' } from POST /roles" do
      params_from(:post, "/roles").should == {:controller => "roles", :action => "create"}
    end

    it "should generate params { :controller => 'roles', action => 'show', id => '1' } from GET /roles/1" do
      params_from(:get, "/roles/1").should == {:controller => "roles", :action => "show", :id => "1"}
    end

    it "should generate params { :controller => 'roles', action => 'edit', id => '1' } from GET /roles/1;edit" do
      params_from(:get, "/roles/1/edit").should == {:controller => "roles", :action => "edit", :id => "1"}
    end

    it "should generate params { :controller => 'roles', action => 'update', id => '1' } from PUT /roles/1" do
      params_from(:put, "/roles/1").should == {:controller => "roles", :action => "update", :id => "1"}
    end

    it "should generate params { :controller => 'roles', action => 'destroy', id => '1' } from DELETE /roles/1" do
      params_from(:delete, "/roles/1").should == {:controller => "roles", :action => "destroy", :id => "1"}
    end
  end
end
