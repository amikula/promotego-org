require File.dirname(__FILE__) + '/../spec_helper'

describe CsvLoader do
  before(:each) do
    @rows = [
      {
        'Name' => 'Western Mass. Go Club', 'Meeting_City' => 'Amherst', 'State' => 'MA',
        'Web Site' => 'www.cookwood.com/personal/go', 'Meeting_HTML' => 'Description',
        'Contact_HTML' =>
            "<a href=\"mailto:testemail@host.com\">Club Contact</a><br>\r\n413 555 1212<br>\r\n 414 555 1212",
        'Expire' => '04/29/09 00:00:00', 'DO_NOT_DISPLAY' => 0, 'Contact' => 'Joe Contact',
        'Address' => '123 Address Street', 'City' => 'Belchertown', 'ZIP' => 'XXXXX-XXXX',
        'Telephone' => '413-555-1212', 'Email' => 'private@email.com', 'chapter' => 'WMGC'
      },
      {
        'Name' => 'Yu Go Club', 'Meeting_City' => 'Pasadena', 'State' => 'CA',
        'Web Site' => '',
        'Meeting_HTML' =>
            " 20 N. Raymond Ave,<br>\r\n Suite 200<br>\r\nWednesday 6:30-10:00 pm<br>\r\nFree beginner lessons every week",
        'Contact_HTML' =>
            "<a href=\"mailto:testemail@testing.com\">Club Contact 2</a><br>\r\n626-555-1212",
        'Expire' => '08/17/2009 00:00:00', 'DO_NOT_DISPLAY' => 1, 'Contact' => 'Jack Contact',
        'Address' => '234 Address Street', 'City' => 'Pasadena', 'ZIP' => '91103',
        'Telephone' => '626-555-1212', 'Email' => 'private@test.com', 'chapter' => 'YUGO'
      }
    ]
  end

  describe :club_from do
    it "has the correct basic attributes" do
      club = CsvLoader.club_from(@rows[0])

      club.name.should == 'Western Mass. Go Club'
      club.street_address.should == nil
      club.city.should == 'Amherst'
      club.state.should == 'MA'
      club.contacts.size.should == 1
      club.contacts[0][:name].should == 'Club Contact'
      club.contacts[0][:phone].should include({:number => '413-555-1212'})
      club.contacts[0][:phone].should include({:number => '414-555-1212'})
      club.url.should == 'http://www.cookwood.com/personal/go'
      club.description.should == 'Description'
      club.hidden?.should be_false
    end

    describe 'with AGA affiliation' do
      before(:each) do
        @aga = mock_model(Affiliate, :name => 'AGA')
        Affiliate.should_receive(:find_by_name).with('AGA').and_return(@aga)

        @club = mock_model(Location)
        @affiliations = []
        @club.should_receive(:affiliations).and_return(@affiliations)
        Location.should_receive(:new).and_return(@club)
      end

      it 'creates an AGA affiliation with the correct expires time' do
        Affiliation.should_receive(:new).
          with(hash_including(:location => @club, :affiliate => @aga, :expires => Date.parse('4/29/2009'))).and_return(:affiliation)
        @affiliations.should_receive(:<<).with(:affiliation)

        CsvLoader.club_from(@rows[0])
      end

      it 'creates an affiliation with the correct contact address' do
        Affiliation.should_receive(:new).
          with(hash_including(:contact_name => 'Joe Contact', :contact_address => '123 Address Street',
                              :contact_city => 'Belchertown', :contact_state => 'MA',
                              :contact_zip => 'XXXXX-XXXX', :contact_telephone => '413-555-1212',
                              :contact_email => 'private@email.com')).and_return(:affiliation)

        CsvLoader.club_from(@rows[0])
      end

      it 'saves the chapter id as the foreign_key' do
        Affiliation.should_receive(:new).
          with(hash_including(:foreign_key => 'WMGC'))

        CsvLoader.club_from(@rows[0])
      end
    end

    it "supports address parsing" do
      club = CsvLoader.club_from(@rows[1])

      club.name.should == 'Yu Go Club'
      club.street_address.should == '20 N. Raymond Ave'
      club.city.should == 'Pasadena'
      club.state.should == 'CA'
      club.contacts.size.should == 1
      club.contacts[0][:name].should == 'Club Contact 2'
      club.contacts[0][:phone].should include({:number => '626-555-1212'})
      club.url.should == nil
      club.description.should == " 20 N. Raymond Ave,<br> Suite 200<br>Wednesday 6:30-10:00 pm<br>Free beginner lessons every week"
      club.hidden?.should be_true
    end

    it "doesn't break when expire field is empty" do
      row = @rows[1]
      row['Expire'] = ''

      club = nil
      lambda{club = CsvLoader.club_from(row)}.should_not raise_error
    end
  end

  describe :load_mdb do
    it 'creates the AGA affiliate if it doesn\'t already exist' do
      FasterCSV.stub!(:foreach)
      Affiliate.stub!(:find_by_name).with('AGA').and_return(nil)
      Affiliate.should_receive(:create!).with(:name => 'AGA', :full_name => 'American Go Association')

      CsvLoader.load_mdb(:filename)
    end

    it 'does not create the AGA affiliate if it already exists' do
      FasterCSV.stub!(:foreach)
      Affiliate.stub!(:find_by_name).with('AGA').and_return(mock_model(Affiliate, :name => 'AGA'))
      Affiliate.should_not_receive(:create!)

      CsvLoader.load_mdb(:filename)
    end

    it "passes the filename to FasterCSV to parse the file" do
      FasterCSV.should_receive(:foreach).with(:filename, :headers => true)

      CsvLoader.load_mdb(:filename)
    end
  end

  describe :save_or_update_club do
    before(:each) do
      @club1_affiliation = stub_model(Affiliation, :affiliate_id => 42, :foreign_key => 'XYZ')
      @club1 = stub_model(Location, :name => 'First Club', :slug => 'first-club', :street_address => "123 first st.",
                          :affiliations => [@club1_affiliation], :url => 'first-club-url')
      @dbclub1 = stub_model(Location, :name => 'First Club', :slug => 'first-club', :street_address => "123 first st.",
                          :affiliations => [@club1_affiliation], :url => 'first-club-url')
      @club2 = stub_model(Location, :name => 'First Club', :slug => 'first-club', :street_address => "124 first st.")
      @club3 = stub_model(Location, :name => 'Some Other Club', :slug => 'first-club', :street_address => "1313 thirteenth st.")
      @club4 = stub_model(Location, :name => 'First Club', :slug => 'first-club-2', :street_address => "123 first st.")

      CsvLoader.stub!(:puts)

      Affiliation.stub!(:find).with(:first, anything).and_return(nil)
      Location.stub!(:find).with(:first, anything).and_return(nil)
      Location.stub!(:find).with(:all, anything).and_return([])
    end

    it 'updates the club if the AGA foreign_key is found' do
      @club1_affiliation.stub!(:location).and_return(@dbclub1)
      Affiliation.should_receive(:find).with(:first, :conditions => ['affiliate_id = ? and foreign_key = ?', 42, 'XYZ'],
                                             :include => :location).and_return(@club1_affiliation)
      CsvLoader.should_receive(:update_club!).with(@dbclub1, @club1)

      CsvLoader.save_or_update_club(@club1)
    end

    it "saves the club if no slug matches this club's slug" do
      Affiliation.stub!(:find).with(:first, anything).and_return(nil)
      @club1.should_receive(:save).and_return(true)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'updates the club if a slug matches and the match is close enough' do
      Location.should_receive(:find).with(:all, anything).and_return([@club2])
      CsvLoader.should_receive(:update_club!).with(@club2, @club1)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'saves the club if a slug matches and the match is not close enough' do
      Location.should_receive(:find).with(:all, anything).and_return([@club3])
      @club1.should_receive(:save).and_return(true)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'updates the correct matching club if multiple partial matches for a slug exist' do
      Location.should_receive(:find).with(:all, :conditions => ['slug LIKE ?', 'first-club%']).
        and_return([@club3, @club4])
      CsvLoader.should_receive(:update_club!).with(@club4, @club1)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'matches clubs when the urls match' do
      Location.should_receive(:find).with(:first, :conditions => ['url = ?', 'first-club-url']).
        and_return(@club3)
      CsvLoader.should_receive(:update_club!).with(@club3, @club1)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'does not match clubs when the urls match and the url is in the exception list' do
      exception = 'http://www.erols.com/jgoon/links-go.htm'
      @club3.stub!(:url).and_return(exception)
      @club1.stub!(:url).and_return(exception)
      @club1.should_receive(:save).and_return(true)

      CsvLoader.save_or_update_club(@club1)
    end
  end

  describe :update_club! do
    before(:each) do
      @db_affiliation = mock_model(Affiliation, :affiliate_id => 1, :expires => 3.months.from_now)
      @db_affiliation.stub!(:attributes=)
      @db_affiliation.stub!(:save).and_return(true)
      @db_club = mock_model(Location, :affiliations => [@db_affiliation], :slug => 'db-club-slug')
      @db_club.stub!(:attributes=)
      @db_club.stub!(:save).and_return(true)
      @new_aff_attributes = {}
      @new_affiliation = mock_model(Affiliation, :attributes => @new_aff_attributes, :affiliate_id => 1,
                                    :expires => 4.months.from_now)
      @new_club = mock_model(Location, :attributes => :new_club_attributes, :affiliations => [@new_affiliation])
      CsvLoader.stub!(:puts)
      CsvLoader.stub!(:filter_attributes)
    end

    it 'updates the club with filtered attributes from the new club' do
      CsvLoader.should_receive(:filter_attributes).with(:new_club_attributes).and_return(:filtered_attributes)
      @db_club.should_receive(:attributes=).with(:filtered_attributes)
      @db_club.should_receive(:save).and_return(true)

      CsvLoader.update_club!(@db_club, @new_club)
    end

    it 'updates the affiliation info' do
      @db_affiliation.should_receive(:attributes=).with(@new_aff_attributes)
      @db_affiliation.should_receive(:save).and_return(true)

      CsvLoader.update_club!(@db_club, @new_club)
    end

    it 'updates the correct affiliation when there is more than one' do
      other_affiliation = mock_model(Affiliation, :affiliate_id => 2)
      other_affiliation.should_not_receive(:attributes=)
      @db_affiliation.should_receive(:attributes=).with(@new_aff_attributes)
      @db_affiliation.should_receive(:save).and_return(true)
      @db_club.stub!(:affiliations).and_return([other_affiliation, @db_affiliation])

      CsvLoader.update_club!(@db_club, @new_club)
    end

    it 'does not update attributes on the affiliation which are nil on the new affiliation' do
      @new_affiliation.stub!(:attributes).and_return(:foo => :bar, :baz => nil, :xyzzy => nil)
      @db_affiliation.should_receive(:attributes=).with(:foo => :bar)
      @db_affiliation.should_receive(:save).and_return(true)

      CsvLoader.update_club!(@db_club, @new_club)
    end

    it 'does not get an error when there are no affiliations on both old and new club' do
      @db_club.stub!(:affiliations).and_return([])
      @new_club.stub!(:affiliations).and_return([])

      lambda{CsvLoader.update_club!(@db_club, @new_club)}.should_not raise_error
    end

    it 'does not get an error when there are no affiliations on new club' do
      @new_club.stub!(:affiliations).and_return([])

      lambda{CsvLoader.update_club!(@db_club, @new_club)}.should_not raise_error
    end

    it 'does not get an error when there are no affiliations on old club' do
      @db_club.stub!(:affiliations).and_return([])

      lambda{CsvLoader.update_club!(@db_club, @new_club)}.should_not raise_error
    end

    it 'updates the expiration date if newer than the old expiration date' do
      @db_affiliation.stub!(:expires).and_return(3.months.from_now)
      new_expire = 1.year.from_now
      @new_affiliation.stub!(:expires).and_return(new_expire)
      @new_aff_attributes['expires'] = new_expire
      @new_aff_attributes['other'] = 'other value'

      @db_affiliation.should_receive(:attributes=).with('expires' => new_expire, 'other' => 'other value')
      @db_affiliation.should_receive(:save).and_return(true)

      CsvLoader.update_club!(@db_club, @new_club)
    end

    it 'does not update the expiration date if older than the previous expiration date' do
      @db_affiliation.stub!(:expires).and_return(3.months.from_now)
      @new_affiliation.stub!(:expires).and_return(1.month.from_now)
      @new_aff_attributes['expires'] = 1.month.from_now
      @new_aff_attributes['other'] = 'other value'

      @db_affiliation.should_receive(:attributes=).with('other' => 'other value')
      @db_affiliation.should_receive(:save).and_return(true)

      CsvLoader.update_club!(@db_club, @new_club)
    end
  end

  describe :match_clubs do
    before(:each) do
      @club1 = stub_model(Location, :name => 'First Club', :street_address => "123 first st.")
      @club2 = stub_model(Location, :name => 'First Club', :street_address => "124 first st.")
      @club3 = stub_model(Location, :name => 'Second Club', :street_address => "1313 thirteenth st.")
    end

    it "computes Levenshtein edit distance for each field and returns a composite ratio" do
      CsvLoader.match_clubs(@club1, @club2).should be_close(0, 0.05)
      CsvLoader.match_clubs(@club1, @club3).should_not be_close(0, 0.05)
    end
  end
end
