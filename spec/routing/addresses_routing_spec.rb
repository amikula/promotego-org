require 'spec_helper'

describe AddressesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/addresses" }.should route_to(:controller => "addresses", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/addresses/new" }.should route_to(:controller => "addresses", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/addresses/1" }.should route_to(:controller => "addresses", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/addresses/1/edit" }.should route_to(:controller => "addresses", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/addresses" }.should route_to(:controller => "addresses", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/addresses/1" }.should route_to(:controller => "addresses", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/addresses/1" }.should route_to(:controller => "addresses", :action => "destroy", :id => "1") 
    end
  end
end
