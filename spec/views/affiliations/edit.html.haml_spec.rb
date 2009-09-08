require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/affiliations/edit" do
  include AffiliationsHelper

  before(:each) do
    assigns[:affiliation] = @affiliation = stub_model(Affiliation,
      :new_record? => false
    )
  end

  it "should render edit form" do
    template.should_receive(:render).with(hash_including(:partial => "affiliation_form"))

    render "/affiliations/edit"
  end
end


