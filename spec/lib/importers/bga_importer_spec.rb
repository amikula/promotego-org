require File.dirname(__FILE__) + '/../../spec_helper'

describe Importers::BgaImporter do
  before :all do
    file = File.open(File.join(Rails.root, 'spec', 'files', 'bga_clublist.xml'))
    @doc = Nokogiri::XML.parse(file)
    @doc.root.add_namespace('bga', 'http://www.britgo.org/clublist.dtd')
  end

  def subject
    Importers::BgaImporter
  end

  describe :load_data do
    before :each do
      @source = mock_model(Source)
      Source.stub!(:find_by_name).with('BGA').and_return(@source)
      @file = File.open(File.join(Rails.root, 'spec', 'files', 'bga_clublist.xml'))
    end

    it 'creates a bga source if one does not exist' do
      Source.should_receive(:find_by_name).with('BGA').and_return(nil)
      Source.should_receive(:create).with(:name => 'BGA', :url => 'http://www.britgo.org/clublist/clublist.xml')

      subject.load_data('<root/>')
    end

    it 'does not create a bga source if one already exists' do
      Source.should_receive(:find_by_name).with('BGA').and_return(mock_model(Source))
      Source.should_not_receive(:create)

      subject.load_data('<root/>')
    end

    it "loads 80 clubs from the example file" do
      mock_location = mock(Location, :save => true, :source= => nil)
      subject.should_receive(:load_club).exactly(80).times.and_return(mock_location)

      subject.load_data(@file)
    end

    it "sets source on the loaded locations" do
      mock_location = mock(Location, :save => true)
      mock_location.should_receive(:source=).with(@source).exactly(80).times
      subject.stub!(:load_club).and_return(mock_location)

      subject.load_data(@file)
    end

    it 'saves each club' do
      mock_location = mock(Location, :source= => nil)
      mock_location.should_receive(:save).with(false).exactly(80).times

      subject.stub!(:load_club).and_return(mock_location)

      subject.load_data(@file)
    end
  end

  describe :load_club do
    before(:each) do
      @aberdeen = @doc.xpath("//bga:club[@id='aber']").first
      @arund = @doc.xpath("//bga:club[@id='arund']").first
      @barmouth = @doc.xpath("//bga:club[@id='barmo']").first
      @bath = @doc.xpath("//bga:club[@id='bath']").first
      @belfast = @doc.xpath("//bga:club[@id='belfast']").first
      @bourn = @doc.xpath("//bga:club[@id='bourn']").first
      @walsall = @doc.xpath("//bga:club[@id='walsall']").first
    end

    describe 'with aberdeen club' do
      before(:each) do
        @location = Importers::BgaImporter.load_club(@aberdeen)
      end

      it 'returns a Location object' do
        @location.should be_kind_of(Location)
      end

      it 'has name "Aberdeen"' do
        @location.name.should == 'Aberdeen'
      end

      it 'has country value "GB"' do
        @location.country.should == 'GB'
      end

      it 'has the correct URL' do
        @location.url.should == 'http://games.groups.yahoo.com/group/aberdeen-go/'
      end

      it 'has the correct description' do
        @location.description.should =~ /^The Yahoo website provides/
      end

      it 'has the right latitude and longitude' do
        @location.lng.should == -2.104740
        @location.lat.should == 57.167432
      end

      it 'has the right contact' do
        @location.contacts.should_not be_nil
        contact = @location.contacts[0]
        contact[:name].should == 'Aidan Karley and Russell Ward'
        contact[:email].should == 'aberdeen-go-owner@yahoogroups.com'
      end

      it 'has an address level geocoding' do
        @location.geocode_precision.should == 'address'
      end

      it 'sets the foreign_key to "aber"' do
        @location.foreign_key.should == 'aber'
      end
    end

    describe 'with a club that does not have known meeting places' do
      before(:each) do
        @location = Importers::BgaImporter.load_club(@barmouth)
      end

      it 'has a city level geocoding' do
        @location.geocode_precision.should == 'city'
      end

      it 'gets lat and lng from the club attributes' do
        @location.lng.should == -4.054642
        @location.lat.should == 52.722622
      end
    end

    it 'loads the postal code' do
      @location = Importers::BgaImporter.load_club(@arund)

      @location.zip_code.should == 'BN18 9DF'
    end

    describe 'with a club that has multiple contacts' do
      before(:each) do
        @location = Importers::BgaImporter.load_club(@bath)
      end

      it 'should load all the contacts' do
        @location.contacts[0][:name].should == 'Paul Christie'
        @location.contacts[1][:name].should == 'Ian Sharpe'
      end

      it 'loads phone numbers too' do
        @location.contacts[0][:phone].should be_kind_of(Array)
        @location.contacts[0][:phone][0][:number].should == '01225 428995'
      end
    end

    describe 'with a club that has a phone number with a type' do
      before(:each) do
        @location = Importers::BgaImporter.load_club(@belfast)
      end

      it 'has the correct type on the phone number' do
        @location.contacts[0][:phone][0][:type].should == 'mobile'
      end
    end

    describe 'with a club that has a contact with no email address' do
      before(:each) do
        @location = Importers::BgaImporter.load_club(@bourn)
      end

      it 'loads the name' do
        @location.contacts[0][:name].should == 'Marcus Bennett'
      end

      it 'has a nil email address' do
        @location.contacts[0][:email].should be_nil
      end

      it 'loads the phone number' do
        @location.contacts[0][:phone][0][:number].should == '01202 512655'
      end
    end

    describe 'with a club that has no lat long coordinates' do
      before(:each) do
        @location = Importers::BgaImporter.load_club(@walsall)
      end

      it 'has nil lat and lng' do
        @location.lat.should be_nil
        @location.lng.should be_nil
      end
    end
  end
end
