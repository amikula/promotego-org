require 'spec_helper'

describe "/addresses/index.html.erb" do
  include AddressesHelper

  before(:each) do
    assigns[:addresses] = [
      stub_model(Address),
      stub_model(Address)
    ]
  end

  it "renders a list of addresses" do
    render
  end
end
