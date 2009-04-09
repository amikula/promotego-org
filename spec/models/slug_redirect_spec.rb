require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SlugRedirect do
  before(:each) do
    @valid_attributes = {
      :slug => "value for slug",
      :location_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    SlugRedirect.create!(@valid_attributes)
  end
end
