require 'spec_helper'

describe "/addresses/new" do
  include AddressesHelper

  before(:each) do
    assigns[:address] = stub_model(Address,
      :new_record? => true
    )

    assigns[:address_owner] = @address_owner = stub_model(User,
      :new_record? => true, :login => 'joe_user'
    )
  end

  it "renders new address form" do
    render

    response.should have_tag("form[action=?][method=post]", user_addresses_path(@address_owner)) do
    end
  end
end
