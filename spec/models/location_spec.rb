require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  before(:each) do
    @location = Location.new
  end

  it "should be valid" do
    @location.street_address="1600 Pennsylvania Ave."
    @location.city="Washington"
    @location.state="DC"
    @location.should be_valid
  end

  it "should combine components into a single address for geocoding" do
    @location.street_address="1600 Pennsylvania Ave."
    @location.city="Washington"
    @location.state="DC"
    @location.geocode_address.should == "1600 Pennsylvania Ave., Washington, DC"

    @location.errors.should be_empty
  end

  it "should report an error if at least city and state or zip code is not present" do
    @location.street_address="1600 Pennsylvania Ave."

    @location.geocode_address.should == nil
    @location.errors.should_not be_empty
  end

  it "should geocode with city and state or zip only, if street address is not present" do
    @location.city = "Washington"
    @location.state = "DC"

    @location.geocode_address.should == "Washington, DC"

    @location.errors.should be_empty
  end

  it "should set an error if geocode is not successful" do
    result = mock("geocode_result")
    result.stub!(:success).and_return(false)
    GeoKit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(result)

    @location.geocode.should == nil
    @location.errors.should_not be_empty
  end

  it "should belong to a user" do
    # Just checking that I can assign user an location without throwing an error
    # Is there a better way?
    location = Location.new
    location.user = User.new
  end

  describe :user= do
    before(:each) do
      @new_owner = mock_model(User)
      @administrator = mock_model(User)
      @administrator.stub!(:has_role?).with(:administrator).and_return(true)
      @non_administrator = mock_model(User)
      @non_administrator.stub!(:has_role?).with(:administrator).
        and_return(false)
    end

    it "should throw an error if user= is called on a record that is not new" do
      location = Location.new
      location.should_receive(:new_record?).and_return(false)

      lambda{location.user = @new_owner}.should raise_error
    end

    it "should assign user_id if user= is called on a new record" do
      location = Location.new

      location.should_receive(:user_id=).with(@new_owner.id)

      location.user = @new_owner
    end
  end

  describe "change_user" do
    before(:each) do
      @new_owner = mock_model(User)
      @administrator = mock_model(User)
      @administrator.stub!(:has_role?).with(:administrator).and_return(true)
      @non_administrator = mock_model(User)
      @non_administrator.stub!(:has_role?).with(:administrator).
        and_return(false)
    end

    it "should throw an error if user_id= is called on a record that is not new" do
      location = Location.new
      location.should_receive(:new_record?).and_return(false)

      lambda{location.user_id = @new_owner.id}.should raise_error
    end

    it "should allow administrators to change user" do
      @location.stub!(:new_record?).and_return(false)
      @location.should_receive(:write_attribute).with(:user, @new_owner)

      @location.change_user(@new_owner, @administrator)
    end

    it "should allow administrators to change user with a user id" do
      @location.stub!(:new_record?).and_return(false)
      @location.should_receive(:write_attribute).with(:user_id, @new_owner.id)

      @location.change_user(@new_owner.id, @administrator)
    end

    it "should allow administrators to change user with a user id string" do
      @location.stub!(:new_record?).and_return(false)
      @location.should_receive(:write_attribute).with(:user_id, @new_owner.id)

      @location.change_user(@new_owner.id.to_s, @administrator)
    end

    it "should raise SecurityError if non-administrators try to change user" do
      lambda {@location.change_user(@new_owner, @non_administrator)}.
        should raise_error(SecurityError)
    end
  end

  describe :precision do
    it "should have precision :address when address is present" do
      options = Location.valid_options
      options[:street_address] = "Street Address"
      location = Location.new(options)

      location.precision.should == :address
    end

    it "should have precision :city when address is not present" do
      options = Location.valid_options
      options[:street_address] = nil
      location = Location.new(options)

      location.precision.should == :city
    end
  end
end
