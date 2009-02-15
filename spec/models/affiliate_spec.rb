require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliate do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :logo_path => "value for logo_path",
      :admin_role_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Affiliate.create!(@valid_attributes)
  end
end
