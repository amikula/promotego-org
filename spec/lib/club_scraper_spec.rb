require File.dirname(__FILE__) + '/../spec_helper'
require 'hpricot'

describe ClubScraper do
  before(:each) do
    @scraper = ClubScraper.new
    @logger = mock(Logger)
    ClubScraper.stub!(:logger).and_return(@logger)
  end

  describe :is_aga? do
    before(:all) do
      @aga_example = Hpricot(<<-EOF).at('td')
      <td>

          <img src="../images/agalogo.gif">


        &nbsp;
      </td>
      EOF

      @non_aga_example = Hpricot(<<-EOF).at('td')
      <td>

        &nbsp;
      </td>
      EOF

      # Unknown image content
      @strange_example_1 = Hpricot(<<-EOF).at('td')
      <td>

          <img src="www.google.com/favicon.ico">

      </td>
      EOF

      # Unknown non-image content
      @strange_example_2 = Hpricot(<<-EOF).at('td')
      <td>

          This club may or may not be affiliated with AGA

      </td>
      EOF
    end

    it "should return true when AGA logo is present" do
      ClubScraper.is_aga?(@aga_example).should be_true
    end

    it "should return false when AGA logo is not present" do
      ClubScraper.is_aga?(@non_aga_example).should be_false
    end

    it "should log a warning and return false when unknown image is present" do
      @logger.should_receive(:warn)
      ClubScraper.is_aga?(@strange_example_1).should be_false
    end

    it "should log a warning and return false when unknown data is present" do
      @logger.should_receive(:warn)
      ClubScraper.is_aga?(@strange_example_2).should be_false
    end
  end

  describe :get_club_name_city_url do
    before(:all) do
      @club_without_url = Hpricot(<<-EOF).at('td')
      <td>

          Yu Go Club

        <br>
        Pasadena
      </td>
      EOF

      @club_with_url = Hpricot(<<-EOF).at('td')
      <td>

          <a href="http://www.santamonicago.org">Santa Monica Go Club</a>

        <br>
        Santa Monica
      </td>
      EOF

      @missing_club_name = Hpricot(<<-EOF).at('td')
      <td>



      <br>
          Paso Robles
      </td>
      EOF

      @missing_city = Hpricot(<<-EOF).at('td')
      <td>

              Club Without Borders

      <br>

      </td>
      EOF

      @missing_br = Hpricot(<<-EOF).at('td')
      <td>

              Club Without BR


      </td>
      EOF
    end

    it "should return club name and city" do
      ClubScraper.get_club_name_city_url(@club_without_url).should ==
        { :name => "Yu Go Club", :city => "Pasadena" }
    end

    it "should also return URL if present" do
      ClubScraper.get_club_name_city_url(@club_with_url).should ==
        { :name => "Santa Monica Go Club", :city => "Santa Monica",
          :url => "http://www.santamonicago.org" }
    end

    it "should log a warning if club name is missing" do
      @logger.should_receive(:warn)

      ClubScraper.get_club_name_city_url(@missing_club_name).should ==
        { :city => "Paso Robles" }
    end

    it "should log a warning if city is missing" do
      @logger.should_receive(:warn)

      ClubScraper.get_club_name_city_url(@missing_city).should ==
        { :name => "Club Without Borders" }
    end

    it "should log a warning if br is missing" do
      @logger.should_receive(:warn)

      ClubScraper.get_club_name_city_url(@missing_br).should ==
        { :name => "Club Without BR" }
    end
  end

  describe :get_club_contacts do
    it "should handle email only" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        email@domain.com
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:email => "email@domain.com"}]
    end

    it "should handle name with email link" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="mailto:anotheremail@anotherdomain.com">Contact Name</a>
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Contact Name", :email => "anotheremail@anotherdomain.com"}]
    end

    it "should handle hyperlink with email address" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="yetanotheremail@anotherdomain.com">Contact Name</a>
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Contact Name", :email => "yetanotheremail@anotherdomain.com"}]
    end

    it "should salvage broken email links" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="mailto:clubemail@domain.com"Broken Contact</a><br>
        954-555-1212
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Broken Contact", :email => "clubemail@domain.com",
          :phone => [{:number => '954-555-1212'}]}]
    end

    it "should handle name with email link with extra space" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="mailto:anotheremail@anotherdomain.com  ">Contact Name</a>
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Contact Name", :email => "anotheremail@anotherdomain.com"}]
    end

    it "should handle mailto with missing colon" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="mailtoanotheremail@anotherdomain.com">Contact Name</a>
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Contact Name", :email => "anotheremail@anotherdomain.com"}]
    end

    it "should handle phone number only" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        626-555-1212
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:phone => [{:number => "626-555-1212"}]}]
    end

    it "should handle name only" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        Joe Contact
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Joe Contact"}]
    end

    it "should handle name followed by phone number" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        Contact Guy<br>
        213-555-1212
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Contact Guy", :phone => [{:number => "213-555-1212"}]}]
    end

    it "should handle multiple contacts" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="mailto:email@domain.com">Contact Guy</a><br>
        479-555-1212<br>

        Joe Contact<br>
        478-555-1212
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Contact Guy", :email => "email@domain.com",
          :phone => [{:number => "479-555-1212"}]},
         {:name => "Joe Contact", :phone => [{:number => "478-555-1212"}]}]
    end

    it "should handle prefix phone number designations" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        <a href="mailto:email@domain.com">Foo Contact</a><br>
        Cell: 626-555-1212
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Foo Contact", :email => "email@domain.com",
          :phone => [{:type => "cell", :number => "626-555-1212"}]}]
    end

    it "should handle postfix phone number designations" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        Bar Contact<br>
        281-555-1212 home
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Bar Contact",
          :phone => [{:type => "home", :number => "281-555-1212"}]}]
    end

    it "should handle multiple phone numbers" do
      multiple_phone_numbers = Hpricot(<<-EOF).at('td')
      <td>
        Baz Contact<br>
        281-555-1212 home<br>
        713-555-1212 cell
      </td>
      EOF

      ClubScraper.get_club_contacts(multiple_phone_numbers).should ==
        [{:name => "Baz Contact",
          :phone => [{:type => "home", :number => "281-555-1212"},
                     {:type => "cell", :number => "713-555-1212"}]
        }]
    end

    it "should handle international phone numbers" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        Xyzzy Contact<br>
        +100 (0)00 000000
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        [{:name => "Xyzzy Contact",
          :phone => [{:number => "+100 (0)00 000000"}]
        }]
    end

    it "should handle empty fields" do
      element = Hpricot(<<-EOF).at('td')
      <td>
      </td>
      EOF

      ClubScraper.get_club_contacts(element).should ==
        []
    end

    it "should log a warning for bad email address" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        foo @ bar . com
      </td>
      EOF

      @logger.should_receive(:warn).at_least(:once)

      ClubScraper.get_club_contacts(element)
    end

    it "should log a warning for unexpected data" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        I'm a field<br>
        123 address st.<br>
        And I'm all f'd up<br>
        Canada
      </td>
      EOF

      @logger.should_receive(:warn).at_least(:once)

      ClubScraper.get_club_contacts(element)
    end
  end

  describe :get_club_info do
    it "should return the text contained in the field" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        I'm a field<br>
        with some data<br>
        I don't care what I have
      </td>
      EOF

      ClubScraper.get_club_info(element).should ==
        {:info => "I'm a field<br>with some data<br>I don't care what I have"}
    end

    it "should recognize addresses" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        Dude Ranch Library<br>
        1313 Mockingbird Lane<br>
        Saturday 3:00pm - 5:00pm
      </td>
      EOF

      ClubScraper.get_club_info(element).should ==
        { :info => "Dude Ranch Library<br>1313 Mockingbird Lane<br>Saturday 3:00pm - 5:00pm",
          :address => "1313 Mockingbird Lane"}
    end

    it "should use other addresses besides just lane and street" do
      elements = Hpricot(<<-EOF)
      <td>
        1601 Pennsylvania Ave.
      </td>
      <td>
        1601 Pennsylvania Avenue
      </td>
      <td>
        10 S. Sierra Madre Bl.
      </td>
      <td>
        10 S. Sierra Madre Blvd.
      </td>
      <td>
        10 S. Sierra Madre Boulevard
      </td>
      <td>
        10 N. Oracle Road
      </td>
      <td>
        10 N. Oracle Rd.
      </td>
      EOF

      (elements/'td').each do |element|
        ClubScraper.get_club_info(element)[:address].should == element.inner_text.strip
      end
    end

    it "should find addresses in other formats" do
      addresses = ['1635 N Nash St..', '807 E 10th St',
        '11772 Parklawn Drive', '64 East Broadway']

      elements = Hpricot(<<-EOF)
      <td>
        1635 N Nash St..
      </td>
      <td>
        (807 E 10th St)
      </td>
      <td>
        11772 Parklawn Drive, Rockville, MD 20852
      </td>
      <td>
        64 East Broadway
      </td>
      EOF

      (elements/'td').each_with_index do |element, i|
        ClubScraper.get_club_info(element)[:address].should == addresses[i]
      end
    end

    it "should use only the first address it finds" do
      element = Hpricot(<<-EOF).at('td')
      <td>
        1601 Pennsylvania Ave.<br>
        1313 Mockingbird Lane<br>
      </td>
      EOF

      ClubScraper.get_club_info(element)[:address].should == "1601 Pennsylvania Ave."
    end
  end

  describe :get_club_table do
    it "should find the table right after the 'listing' anchor" do
      page = Hpricot(<<-EOF)
      <html>
        <head><title>Test Page</title></head>
        <body>
          <div>
            <table id="wrong1"></table>
            <table id="wrong2"></table>
            <div>
              <a name="listing"></a>
              <table id="correct"></table>
            </div>
            <a name="something else"></a>
            <table id="wrong3"></table>
          </div>
        </body>
      </html>
      EOF

      ClubScraper.get_club_table(page)[:id].should == "correct"
    end
  end

  describe :get_club_from_row do
    it "should return a hash of info about the club" do
      row = Hpricot(<<-EOF).at('tr')
      <tr class='chapList'>
        <td>

            <img src="../images/agalogo.gif">

          &nbsp;
        </td>
        <td>

            Birmingham Go Association

          <br>
          Birmingham
        </td>
        <td><a href="mailto:email@domain.com ">Joe Contact</a><br>

  205-555-1212</td>
        <td>Riverchase Galleria<br>
  in Hoover<br>
  Sunday 3:00-6:00 pm</td>
      </tr>
      EOF

      ClubScraper.get_club_from_row(row).should match_hash(
        { :name => "Birmingham Go Association",
          :city => "Birmingham",
          :contacts => [{:name => "Joe Contact", :email => "email@domain.com",
                         :phone => [{:number => "205-555-1212"}]}],
          :info => "Riverchase Galleria<br>in Hoover<br>Sunday 3:00-6:00 pm",
          :is_aga? => true})
    end
  end

  describe :get_state_from_row do
    it "should extract the state name" do
      row = Hpricot(<<-EOF).at('tr')
      <tr bgcolor='silver'>
        <td colspan="3"><b>Alabama</b></td> <td><a href="#top">back to top</a></td>
      </tr>
      EOF

      ClubScraper.get_state_from_row(row).should match_hash(
        {:state => "Alabama"})
    end

    it "should return 'XX' for empty cell" do
      row = Hpricot(<<-EOF).at('tr')
      <tr bgcolor='silver'>
        <td colspan="3"><b></b></td> <td><a href="#top">back to top</a></td>
      </tr>
      EOF

      ClubScraper.get_state_from_row(row).should match_hash({:state => "XX"})
    end

    it "should return 'XX' for 'Overseas'" do
      row = Hpricot(<<-EOF).at('tr')
      <tr bgcolor='silver'>
        <td colspan="3"><b>Overseas</b></td> <td><a href="#top">back to top</a></td>
      </tr>
      EOF

      ClubScraper.get_state_from_row(row).should match_hash({:state => "XX"})
    end
  end

  describe :is_state_row? do
    it "should return true if bgcolor is silver" do
      row = Hpricot(<<-EOF).at('tr')
      <tr bgcolor='silver'>
        <td colspan="3"><b></b></td> <td><a href="#top">back to top</a></td>
      </tr>
      EOF

      ClubScraper.is_state_row?(row).should be_true
    end

    it "should return false if bgcolor is not silver" do
      row = Hpricot(<<-EOF).at('tr')
      <tr bgcolor='blue'>
        <td colspan="3"><b></b></td> <td><a href="#top">back to top</a></td>
      </tr>
      EOF

      ClubScraper.is_state_row?(row).should be_false
    end

    it "should return false if there is no bgcolor" do
      row = Hpricot(<<-EOF).at('tr')
      <tr>
        <td colspan="3"><b></b></td> <td><a href="#top">back to top</a></td>
      </tr>
      EOF

      ClubScraper.is_state_row?(row).should be_false
    end
  end

  describe(:process_table) do
    it "should get clubs from the table" do
      table = mock(Object)
      rows = [:header_row, :state_row_1, :club_row_1, :state_row_2,
        :club_row_2, :club_row_3]
      table.should_receive(:search).with('/tr').and_return(rows)

      ClubScraper.should_receive(:is_state_row?).and_return(true, false, true, false, false)

      ClubScraper.should_receive(:get_state_from_row).
        and_return({:state => 'California'}, {:state => 'Texas'})

      ClubScraper.should_receive(:get_club_from_row).
        and_return({:name => 'Foo Club'}, {:name => 'Bar Club'},
                   {:name => 'Baz Club'})

      clubs = []

      ClubScraper.process_table(table) do |club|
        clubs << club
      end

      clubs[0].should match_hash({:state => 'California', :name => 'Foo Club'})
      clubs[1].should match_hash({:state => 'Texas', :name => 'Bar Club'})
      clubs[2].should match_hash({:state => 'Texas', :name => 'Baz Club'})
    end
  end

  describe(:get_table_from_url) do
    it "should call get_url with the url, then call get_get_club_table" do
      ClubScraper.should_receive(:get_url).with(:url).and_return(:page)
      ClubScraper.should_receive(:get_club_table).with(:page).and_return(:table)

      ClubScraper.get_table_from_url(:url).should == :table
    end
  end

  describe(:get_clubs_from_url) do
    it "should call get_table_from_url, then process_table" do
      ClubScraper.should_receive(:get_table_from_url).with(:url).
        and_return(:table)
      ClubScraper.should_receive(:process_table).with(:table)

      ClubScraper.get_clubs_from_url(:url, &:block)
    end
  end
end
