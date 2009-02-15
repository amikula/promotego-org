require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Affiliation do
  before(:each) do
    @valid_attributes = {
      :location_id => 1,
      :affiliate_id => 1,
      :expires => Date.today
    }
  end

  it "should create a new instance given valid attributes" do
    Affiliation.create!(@valid_attributes)
  end

  describe 'associations' do
    it 'should have one affiliate' do
      affiliate = mock_model(Affiliate)
      lambda{subject.affiliate = affiliate}.should_not raise_error
    end

    it 'should have one location' do
      location = mock_model(Location)
      lambda{subject.location = location}.should_not raise_error
    end
  end
end
