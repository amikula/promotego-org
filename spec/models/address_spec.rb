require 'spec_helper'

describe Address do
  before(:each) do
    @valid_attributes = {
      :street_address => "value for street_address",
      :city => "value for city",
      :state => "value for state",
      :zip_code => "value for zip_code",
      :lat => 1.5,
      :lng => 1.5,
      :geocode_precision => "value for geocode_precision",
      :public => false,
      :hidden => false,
      :addressable_type => "value for addressable_type",
      :addressable_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Address.create!(@valid_attributes)
  end
end
