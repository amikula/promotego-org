require 'spec_helper'

describe "/addresses/edit" do
  include AddressesHelper

  before(:each) do
    assigns[:address] = @address = stub_model(Address,
      :new_record? => false
    )

    assigns[:address_owner] = @address_owner = stub_model(User,
      :new_record? => false, :login => 'user'
    )
  end

  it "renders the edit address form" do
    render

    response.should have_tag("form[action=#{user_address_path(@address_owner, @address)}][method=post]") do
    end
  end
end
