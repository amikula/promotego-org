require File.dirname(__FILE__) + '/../spec_helper'

describe TypesController do
  describe "route generation" do

    it "should map { :controller => 'types', :action => 'index' } to /types" do
      route_for(:controller => "types", :action => "index").should == "/types"
    end
  
    it "should map { :controller => 'types', :action => 'new' } to /types/new" do
      route_for(:controller => "types", :action => "new").should == "/types/new"
    end
  
    it "should map { :controller => 'types', :action => 'show', :id => 1 } to /types/1" do
      route_for(:controller => "types", :action => "show", :id => 1).should == "/types/1"
    end
  
    it "should map { :controller => 'types', :action => 'edit', :id => 1 } to /types/1/edit" do
      route_for(:controller => "types", :action => "edit", :id => 1).should == "/types/1/edit"
    end
  
    it "should map { :controller => 'types', :action => 'update', :id => 1} to /types/1" do
      route_for(:controller => "types", :action => "update", :id => 1).should == "/types/1"
    end
  
    it "should map { :controller => 'types', :action => 'destroy', :id => 1} to /types/1" do
      route_for(:controller => "types", :action => "destroy", :id => 1).should == "/types/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'types', action => 'index' } from GET /types" do
      params_from(:get, "/types").should == {:controller => "types", :action => "index"}
    end
  
    it "should generate params { :controller => 'types', action => 'new' } from GET /types/new" do
      params_from(:get, "/types/new").should == {:controller => "types", :action => "new"}
    end
  
    it "should generate params { :controller => 'types', action => 'create' } from POST /types" do
      params_from(:post, "/types").should == {:controller => "types", :action => "create"}
    end
  
    it "should generate params { :controller => 'types', action => 'show', id => '1' } from GET /types/1" do
      params_from(:get, "/types/1").should == {:controller => "types", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'types', action => 'edit', id => '1' } from GET /types/1;edit" do
      params_from(:get, "/types/1/edit").should == {:controller => "types", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'types', action => 'update', id => '1' } from PUT /types/1" do
      params_from(:put, "/types/1").should == {:controller => "types", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'types', action => 'destroy', id => '1' } from DELETE /types/1" do
      params_from(:delete, "/types/1").should == {:controller => "types", :action => "destroy", :id => "1"}
    end
  end
end