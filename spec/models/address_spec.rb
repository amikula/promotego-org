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

  describe :to_s do
    it 'returns the zipcode when only zipcode is present' do
      Address.new(:zip_code => 99999).to_s.should == '99999'
    end

    it 'returns the state when only state is present' do
      Address.new(:state => 'CA').to_s.should == 'CA'
    end

    it 'returns city, state when only city and state are present' do
      Address.new(:city => 'Los Angeles', :state => 'CA').to_s.should == 'Los Angeles, CA'
    end

    it 'returns address, zipcode when only address and zip code are present' do
      Address.new(:street_address => '1313 Mockingbird Lane', :zip_code => 66666).to_s.
        should == '1313 Mockingbird Lane, 66666'
    end

    it 'returns address, city, state when only address, city, and state are present' do
      Address.new(:street_address => '1313 Mockingbird Lane', :city => 'Springfield', :state => 'XX').to_s.
        should == '1313 Mockingbird Lane, Springfield, XX'
    end

    it 'returns address, city, state  zipcode' do
      Address.new(:street_address => '1313 Mockingbird Lane', :city => 'Springfield',
                  :state => 'XX', :zip_code => 66666).to_s.
        should == '1313 Mockingbird Lane, Springfield, XX  66666'
    end
  end
end
