require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/affiliations/new.html.erb" do
  include AffiliationsHelper

  before(:each) do
    assigns[:affiliation] = stub_model(Affiliation,
      :new_record? => true
    )
  end

  it "should render new form" do
    template.should_receive(:render).with(hash_including(:partial => "affiliation_form"))

    render "/affiliations/new.html.erb"
  end
end


