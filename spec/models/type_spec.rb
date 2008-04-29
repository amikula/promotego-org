require File.dirname(__FILE__) + '/../spec_helper'

describe Type do
  before(:each) do
    @type = Type.new
  end

  it "should be valid" do
    @type.should be_valid
  end
end
