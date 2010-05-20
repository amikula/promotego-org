require 'spec_helper'

describe "/addresses/new.html.erb" do
  include AddressesHelper

  before(:each) do
    assigns[:address] = stub_model(Address,
      :new_record? => true
    )
  end

  it "renders new address form" do
    render

    response.should have_tag("form[action=?][method=post]", addresses_path) do
    end
  end
end
