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
    it "should have the correct basic attributes" do
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

      it 'should create an AGA affiliation with the correct expires time' do
        Affiliation.should_receive(:new).
          with(hash_including(:location => @club, :affiliate => @aga, :expires => Date.parse('4/29/2009'))).and_return(:affiliation)
        @affiliations.should_receive(:<<).with(:affiliation)

        CsvLoader.club_from(@rows[0])
      end

      it 'should create an affiliation with the correct contact address' do
        Affiliation.should_receive(:new).
          with(hash_including(:contact_name => 'Joe Contact', :contact_address => '123 Address Street',
                              :contact_city => 'Belchertown', :contact_state => 'MA',
                              :contact_zip => 'XXXXX-XXXX', :contact_telephone => '413-555-1212',
                              :contact_email => 'private@email.com')).and_return(:affiliation)

        CsvLoader.club_from(@rows[0])
      end

      it 'should save the chapter id as the foreign_key' do
        Affiliation.should_receive(:new).
          with(hash_including(:foreign_key => 'WMGC'))

        CsvLoader.club_from(@rows[0])
      end
    end

    it "should support address parsing" do
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

    it "shouldn't break when expire field is empty" do
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

    it 'should create the AGA affiliate if it doesn\'t already exist' do
      FasterCSV.stub!(:foreach)
      Affiliate.stub!(:find_by_name).with('AGA').and_return(nil)
      Affiliate.should_receive(:create!).with(:name => 'AGA', :full_name => 'American Go Association')

      CsvLoader.load_mdb(:filename)
    end

    it 'should not create the AGA affiliate if it already exists' do
      FasterCSV.stub!(:foreach)
      Affiliate.stub!(:find_by_name).with('AGA').and_return(mock_model(Affiliate, :name => 'AGA'))
      Affiliate.should_not_receive(:create!)

      CsvLoader.load_mdb(:filename)
    end

    it "should pass the filename to FasterCSV to parse the file" do
      FasterCSV.should_receive(:foreach).with(:filename, :headers => true)

      CsvLoader.load_mdb(:filename)
    end

    it "should assign a type of 'club' to each result and save the record" do
      Type.should_receive(:find_by_name).once.with("Go Club").and_return(@type)
      FasterCSV.should_receive(:foreach).and_yield(:row1).and_yield(:row2)

      [:row1, :row2].each do |row|
        club = mock(Location)
        club.should_receive(:type_id=).ordered.with(@type.id)
        club.should_receive(:save!).ordered
        CsvLoader.should_receive(:club_from).with(row).and_return(club)
      end

      CsvLoader.load_mdb(:filename)
    end
  end
end

def club_inspect(row)
  row.headers.sort.each do |header|
    printf "%20s: %s\n", header, row[header]
  end
end
