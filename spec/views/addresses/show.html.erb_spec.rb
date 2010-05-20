require 'spec_helper'

describe "/addresses/show.html.erb" do
  include AddressesHelper
  before(:each) do
    assigns[:address] = @address = stub_model(Address)
  end

  it "renders attributes in <p>" do
    render
  end
end
