require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliationsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "affiliations", :action => "index").should == "/affiliations"
    end

    it "should map #new" do
      route_for(:controller => "affiliations", :action => "new").should == "/affiliations/new"
    end

    it "should map #show" do
      route_for(:controller => "affiliations", :action => "show", :id => '1').should == {:path => "/affiliations/1", :method => 'get'}
    end

    it "should map #edit" do
      route_for(:controller => "affiliations", :action => "edit", :id => '1').should == {:path => "/affiliations/1/edit", :method => 'get'}
    end

    it "should map #update" do
      route_for(:controller => "affiliations", :action => "update", :id => '1').should == {:path => "/affiliations/1", :method => 'put'}
    end

    it "should map #destroy" do
      route_for(:controller => 'affiliations', :action => 'destroy', :id => '1').should == {:path => '/affiliations/1', :method => 'delete'}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/affiliations").should == {:controller => "affiliations", :action => "index"}
    end

    it "should generate params for #new" do
      params_from(:get, "/affiliations/new").should == {:controller => "affiliations", :action => "new"}
    end

    it "should generate params for #create" do
      params_from(:post, "/affiliations").should == {:controller => "affiliations", :action => "create"}
    end

    it "should generate params for #show" do
      params_from(:get, "/affiliations/1").should == {:controller => "affiliations", :action => "show", :id => "1"}
    end

    it "should generate params for #edit" do
      params_from(:get, "/affiliations/1/edit").should == {:controller => "affiliations", :action => "edit", :id => "1"}
    end

    it "should generate params for #update" do
      params_from(:put, "/affiliations/1").should == {:controller => "affiliations", :action => "update", :id => "1"}
    end

    it "should generate params for #destroy" do
      params_from(:delete, "/affiliations/1").should == {:controller => "affiliations", :action => "destroy", :id => "1"}
    end
  end
end
