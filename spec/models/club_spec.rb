require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Club do
  before(:each) do
    @valid_attributes = {
      :contacts => "value for contacts",
      :description => "value for description",
      :foreign_key => "value for foreign_key",
      :hidden => false,
      :hours => "value for hours",
      :name => "value for name",
      :slug => "value for slug",
      :source_id => "value for source_id",
      :url => "value for url",
      :user_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Club.create!(@valid_attributes)
  end
end
