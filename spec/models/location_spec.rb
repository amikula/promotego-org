require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  before(:each) do
    @location = Location.new
  end

  it "should be valid" do
    @location.attributes = Location.valid_options
    @location.should be_valid
  end

  describe :associations do
    it 'should have affiliations' do
      subject.affiliations.should be_kind_of(Array)
    end

    it 'should have affiliates' do
      subject.affiliates.should be_kind_of(Array)
    end
  end

  describe :geocode_address do
    it "should combine components into a single address for geocoding" do
      @location.street_address="1600 Pennsylvania Ave."
      @location.city="Washington"
      @location.state="DC"
      @location.geocode_address.should == "1600 Pennsylvania Ave., Washington, DC"

      @location.errors.should be_empty
    end

    it "should geocode with city and state or zip only, if street address is not present" do
      @location.city = "Washington"
      @location.state = "DC"

      @location.geocode_address.should == "Washington, DC"

      @location.errors.should be_empty
    end

    it "should not include that extraneous comma" do
      @location.state = "Iowa"
      @location.country = "USA"

      @location.geocode_address.should == "Iowa, USA"

      @location.errors.should be_empty
    end

    it 'returns the zip code if state is nil' do
      @location.state = nil
      @location.country = 'GB'
      @location.zip_code = 'zip_code'

      @location.geocode_address.should == 'zip_code, GB'
    end
  end

  describe :city_state_zip do
    it "should show 'city, state zip' if all three are present" do
      @location.city = 'City'
      @location.state = 'State'
      @location.zip_code = '00000'

      @location.city_state_zip.should == 'City, State 00000'
    end

    it "should show 'city, state' if zip code is not present" do
      @location.city = 'City'
      @location.state = 'State'

      @location.city_state_zip.should == 'City, State'
    end

    it "should show 'city, zip' if state is not present" do
      @location.city = 'City'
      @location.zip_code = '00000'

      @location.city_state_zip.should == 'City, 00000'
    end

    it "should show 'state zip' if city is not present" do
      @location.state = 'State'
      @location.zip_code = '00000'

      @location.city_state_zip.should == 'State 00000'
    end

    it "should show 'city' if only city is present" do
      @location.city = 'City'

      @location.city_state_zip.should == 'City'
    end

    it "should show 'state' if only state is present" do
      @location.state = 'State'

      @location.city_state_zip.should == 'State'
    end

    it "should show 'zip' if only zip is present" do
      @location.zip_code = '00000'

      @location.city_state_zip.should == '00000'
    end
  end

  it "should set an error if geocode is not successful" do
    result = mock("geocode_result")
    result.stub!(:success).and_return(false)
    Geokit::Geocoders::MultiGeocoder.stub!(:geocode).and_return(result)

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

  describe :before_save do
    before(:each) do
      @location = Location.new(:name => 'Game Empire', :slug => 'game-empire')
      @location.stub!(:name_changed?).and_return(false)
      @location.stub!(:slug_changed?).and_return(false)
    end

    it "cleans blank contacts from the contacts array" do
      @location.should_receive(:clean_empty_contacts)

      @location.before_save
    end

    it "generates slug if it is blank" do
      @location.slug = nil
      @location.should_receive(:first_available_slug).with('game-empire').and_return(:slug)

      @location.before_save

      @location.slug.should == :slug
    end

    it 'generates slug if name has changed' do
      @location.name = 'Game Fiefdom'
      @location.stub!(:name_changed?).and_return(true)
      @location.stub!(:slug_changed?).and_return(true)
      @location.should_receive(:changes).at_least(1).times.and_return('name' => ['Game Empire', 'Game Fiefdom'], 'slug' => [nil, 'slug'])
      @location.should_receive(:first_available_slug).with('game-fiefdom').and_return(:slug)

      @location.before_save

      @location.slug.should == :slug
    end

    it 'does not generate the slug if the name changed in a way that would not change its slug' do
      @location.stub!(:name_changed?).and_return(true)
      @location.should_receive(:changes).and_return('name' => ['Game Empire', 'Game*Empire'])
      @location.should_not_receive(:first_available_slug)

      @location.before_save

      @location.slug.should == 'game-empire'
    end

    it 'creates a SlugRedirect if the slug changed anywhere in the system' do
      @location.should_receive(:slug_changed?).and_return(true)
      @location.should_receive(:changes).and_return('slug' => ['42', 'game-empire'])
      @location.should_not_receive(:first_available_slug)
      slugredirect = mock(SlugRedirect)
      SlugRedirect.should_receive(:new).with(:slug => '42').and_return(slugredirect)
      @location.slug_redirects.should_receive(:<<).with(slugredirect)

      @location.before_save

      @location.slug.should == 'game-empire'
    end

    it 'deletes existing SlugRedirects that would conflict with the current one' do
      @location.stub!(:slug_changed?).and_return(true)
      @location.stub!(:changes).and_return('slug' => ['42', 'game-empire'])
      @location.stub!(:first_available_slug)
      slugredirect = mock(SlugRedirect)
      SlugRedirect.stub!(:new).with(:slug => '42').and_return(slugredirect)
      @location.slug_redirects.stub!(:<<).with(slugredirect)

      SlugRedirect.should_receive(:destroy_all).with(['slug = ?', 'game-empire'])

      @location.before_save

      @location.slug.should == 'game-empire'
    end
  end

  describe :clean_empty_contacts do
    before(:each) do
      @location = Location.new(Location.valid_options)
    end

    it "shouldn't fail if contacts is nil" do
      @location.contacts = nil
      lambda{@location.send(:clean_empty_contacts)}.should_not raise_error
    end

    it "should remove empty hashes from the contacts array" do
      @location.contacts = [{:name => ""}, {:foo => :bar}, {}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == [{:foo => :bar}]
    end

    it "should treat hashes with only blank phone numbers as blank" do
      @location.contacts = [{:email => "", :phone => [{:number => "", :type => "cell"}]}, {:foo => :bar}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == [{:foo => :bar}]
    end

    it "should recognize blank phone numbers with string keys" do
      @location.contacts = [{"email" => "", "phone" => [{"number" => "", "type" => "cell"}]}, {:foo => :bar}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == [{:foo => :bar}]
    end

    it "should treat hashes with phone numbers with empty types as blank" do
      @location.contacts = [{:email => "", :phone => [{:number => "", :type => ""}]}, {:foo => :bar}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == [{:foo => :bar}]
    end

    it "should not treat hashes with actual phone numbers as blank" do
      @location.contacts = [{:phone => [{:number => "626-555-1212", :type => "cell"}]}, {:foo => :bar}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == [{:phone => [{:number => "626-555-1212", :type => "cell"}]}, {:foo => :bar}]
    end

    it "should clean phone numbers even if contact is not blank" do
      @location.contacts = [{:name => "Name", :phone => [{:number => "626-555-1212", :type => "cell"}, {:number => "", :type => ""}]}, {:foo => :bar}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == [{:name => "Name", :phone => [{:number => "626-555-1212", :type => "cell"}]}, {:foo => :bar}]
    end

    it "should leave empty arrays as nil" do
      @location.contacts = [{}]
      @location.send(:clean_empty_contacts)
      @location.contacts.should == nil
    end
  end

  describe :first_available_slug do
    before(:each) do
      @location = Location.new(:id => 42)
      Location.stub!(:find).with(:all, anything).and_return([])
      SlugRedirect.stub!(:find).with(:all, anything).and_return([])
    end

    def get_slug(name)
      @location.send(:first_available_slug, name)
    end

    it 'adds -2 to the end if a slug already exists with the value' do
      Location.stub!(:find).and_return([mock_model(Location, :slug => 'foo-bar')])

      get_slug('foo-bar').should == 'foo-bar-2'
    end

    it 'does not add -2 to the end if a slug with a similar unequal value exists' do
      Location.stub!(:find).and_return([mock_model(Location, :slug => 'foo-bar-baz')])

      get_slug('foo-bar').should == 'foo-bar'
    end

    it 'adds -3 if the slug exists and -2 also exists' do
      Location.stub!(:find).and_return([mock_model(Location, :slug => 'foo-bar'),
                                                 mock_model(Location, :slug => 'foo-bar-2')])

      get_slug('foo-bar').should == 'foo-bar-3'
    end

    it 'adds -2 if the slug exists as a SlugRedirect' do
      SlugRedirect.stub!(:find).and_return([mock_model(SlugRedirect, :slug => 'foo-bar', :location_id => 7)])

      get_slug('foo-bar').should == 'foo-bar-2'
    end

    it 'recycles the slug if a SlugRedirect is found that points to this location' do
      @location.name = "Foo Bar"
      @location.id = 42
      SlugRedirect.stub!(:find).and_return([mock_model(SlugRedirect, :slug => 'foo-bar', :location_id => @location.id)])

      @location.send(:first_available_slug, 'foo-bar').should == 'foo-bar'
    end
  end

  describe :validate do
    before(:each) do
      @location.attributes = Location.valid_options
    end

    it 'fails validation with "must be selected" if country is "--"' do
      @location.country = '--'
      @location.errors.should_receive(:add).with(:country, 'must be selected')

      @location.send(:validate)
    end

    it 'fails validation with "must be selected" if state is "--"' do
      @location.state = '--'
      @location.errors.should_receive(:add).with(:state, 'must be selected')

      @location.send(:validate)
    end

    it 'fails validation if we have a list of states for the given country and the state does not match' do
      @location.country = 'US'
      @location.state = 'XX'
      @location.errors.should_receive(:add).with(:state, "'XX' is not a valid state")

      @location.send(:validate)
    end

    it 'passes validation if we have a list of states for the given country and the state matches an abbreviation' do
      @location.country = 'US'
      @location.state = 'CA'
      @location.should_not_receive(:errors)

      @location.send(:validate)
    end

    it 'passes validation if we have a list of states for the given country and the state matches a state name' do
      @location.country = 'US'
      @location.state = 'Virginia'
      @location.should_not_receive(:errors)

      @location.send(:validate)
    end

    it 'passes validation if we do not have a list of states for the given country' do
      @location.country = 'XX'
      @location.state = 'YY'
      @location.should_not_receive(:errors)

      @location.send(:validate)
    end
  end

  describe :driving_directions? do
    it 'returns true when geocode_precision is address and street_address is not nil' do
      @location.stub!(:geocode_precision).and_return('address')
      @location.stub!(:street_address).and_return('some_address')

      @location.driving_directions?.should be_true
    end

    it 'returns false when geocode_precision is not address and street_address is not nil' do
      @location.stub!(:geocode_precision).and_return('city')
      @location.stub!(:street_address).and_return('some_address')

      @location.driving_directions?.should be_false
    end


    it 'returns false when geocode_precision is address and street_address is nil' do
      @location.stub!(:geocode_precision).and_return('address')
      @location.stub!(:street_address).and_return('')

      @location.driving_directions?.should be_false
    end
  end
end
