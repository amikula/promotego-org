require 'spec_helper'

describe AddressesController do
  describe "routing" do
    describe 'for users' do
      it "recognizes and generates #new" do
        { :get => "/users/joe/addresses/new" }.should route_to(:user_id => 'joe', :controller => "addresses", :action => "new")
      end

      it "recognizes and generates #edit" do
        { :get => "/users/joe/addresses/1/edit" }.should route_to(:user_id => 'joe', :controller => "addresses", :action => "edit", :id => "1")
      end

      it "recognizes and generates #create" do
        { :post => "/users/joe/addresses" }.should route_to(:user_id => 'joe', :controller => "addresses", :action => "create") 
      end

      it "recognizes and generates #update" do
        { :put => "/users/joe/addresses/1" }.should route_to(:user_id => 'joe', :controller => "addresses", :action => "update", :id => "1") 
      end

      it "recognizes and generates #destroy" do
        { :delete => "/users/joe/addresses/1" }.should route_to(:user_id => 'joe', :controller => "addresses", :action => "destroy", :id => "1") 
      end
    end
  end
end
