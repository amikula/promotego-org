require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/affiliations/new.html.erb" do
  include AffiliationsHelper

  before(:each) do
    assigns[:affiliation] = stub_model(Affiliation,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/affiliations/new.html.erb"

    response.should have_tag("form[action=?][method=post]", affiliations_path) do
    end
  end
end


