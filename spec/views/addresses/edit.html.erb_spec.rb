require 'spec_helper'

describe "/addresses/edit.html.erb" do
  include AddressesHelper

  before(:each) do
    assigns[:address] = @address = stub_model(Address,
      :new_record? => false
    )
  end

  it "renders the edit address form" do
    render

    response.should have_tag("form[action=#{address_path(@address)}][method=post]") do
    end
  end
end
