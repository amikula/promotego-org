require File.dirname(__FILE__) + '/../spec_helper'

describe Role do
  before(:each) do
    @role = Role.new
  end

  it "should be valid" do
    @role.should be_valid
  end
end
