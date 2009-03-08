require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/affiliations/index.html.erb" do
  include AffiliationsHelper

  before(:each) do
    assigns[:affiliations] = [
      stub_model(Affiliation),
      stub_model(Affiliation)
    ]
  end

  it "should render list of affiliations" do
    render "/affiliations/index.html.erb"
  end
end

