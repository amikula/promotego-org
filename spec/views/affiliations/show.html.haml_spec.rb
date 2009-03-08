require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/affiliations/show.html.erb" do
  include AffiliationsHelper
  before(:each) do
    assigns[:affiliation] = @affiliation = stub_model(Affiliation, :affiliate => stub_model(Affiliate),
                                                      :location => stub_model(Location))
  end

  it "should render attributes in <p>" do
    render "/affiliations/show.html.erb"
  end
end

