require File.dirname(__FILE__) + '/../spec_helper'
require 'pp'

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
      club.contacts[0][:phone].should include({:number => '413 555 1212'})
      club.contacts[0][:phone].should include({:number => '414 555 1212'})
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
    before :each do
      @type = mock_model(Type)
      Type.stub!(:find_by_name).and_return(@type)
    end

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

    it "assigns a type of 'club' to each result and save the record" do
      Type.should_receive(:find_by_name).once.with("Go Club").and_return(@type)
      FasterCSV.should_receive(:foreach).and_yield(:row1).and_yield(:row2)

      [:row1, :row2].each do |row|
        club = mock(Location, :name => "club #{row}")
        club.should_receive(:type_id=).with(@type.id)
        CsvLoader.should_receive(:save_or_update_club).with(club)
        CsvLoader.should_receive(:club_from).with(row).and_return(club)
      end

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
      @club4 = stub_model(Location, :name => 'Some Other Club', :slug => 'first-club', :street_address => "1313 thirteenth st.")
      @club5 = stub_model(Location, :name => 'First Club', :slug => 'first-club-2', :street_address => "123 first st.")

      CsvLoader.stub!(:puts)

      Affiliation.stub!(:find).with(:first, anything).and_return(nil)
      Location.stub!(:find).with(:first, anything).and_return(nil)
      Location.stub!(:find).with(:all, anything).and_return([])
    end

    it 'updates the club if the AGA foreign_key is found' do
      @club1_affiliation.stub!(:location).and_return(@dbclub1)
      Affiliation.should_receive(:find).with(:first, :conditions => ['affiliate_id = ? and foreign_key = ?', 42, 'XYZ'],
                                             :include => :location).and_return(@club1_affiliation)
      CsvLoader.should_receive(:filter_attributes).with(@club1.attributes).and_return(:attributes)
      @dbclub1.should_receive(:update_attributes!).with(:attributes)

      CsvLoader.save_or_update_club(@club1)
    end

    it "saves the club if no slug matches this club's slug" do
      Affiliation.stub!(:find).with(:first, anything).and_return(nil)
      @club1.should_receive(:save!)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'updates the club if a slug matches and the match is close enough' do
      Location.should_receive(:find).with(:all, anything).and_return([@club2])
      CsvLoader.should_receive(:filter_attributes).with(@club1.attributes).and_return(:attributes)
      @club2.should_receive(:update_attributes!).with(:attributes)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'saves the club if a slug matches and the match is not close enough' do
      Location.should_receive(:find).with(:all, anything).and_return([@club3])
      @club1.should_receive(:save!)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'updates the correct matching club if multiple partial matches for a slug exist' do
      Location.should_receive(:find).with(:all, :conditions => ['slug LIKE ?', 'first-club%']).
        and_return([@club4, @club5])
      CsvLoader.should_receive(:filter_attributes).with(@club1.attributes).and_return(:attributes)
      @club5.should_receive(:update_attributes!).with(:attributes)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'matches clubs when the urls match' do
      Location.should_receive(:find).with(:first, :conditions => ['url = ?', 'first-club-url']).
        and_return(@club4)
      CsvLoader.should_receive(:filter_attributes).with(@club1.attributes).and_return(:attributes)
      @club4.should_receive(:update_attributes!).with(:attributes)

      CsvLoader.save_or_update_club(@club1)
    end

    it 'does not match clubs when the urls match and the url is in the exception list' do
      exception = 'http://www.erols.com/jgoon/links-go.htm'
      @club4.stub!(:url).and_return(exception)
      @club1.stub!(:url).and_return(exception)
      @club1.should_receive(:save!)

      CsvLoader.save_or_update_club(@club1)
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
