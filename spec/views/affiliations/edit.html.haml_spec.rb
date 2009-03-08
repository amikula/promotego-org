require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/affiliations/edit.html.erb" do
  include AffiliationsHelper

  before(:each) do
    assigns[:affiliation] = @affiliation = stub_model(Affiliation,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/affiliations/edit.html.erb"

    response.should have_tag("form[action=#{affiliation_path(@affiliation)}][method=post]") do
    end
  end
end


