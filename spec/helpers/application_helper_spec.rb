require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe :active_countries do
    before(:each) do
      @visible = mock('named_scope')
      Location.stub!(:visible).and_return(@visible)

      # Apparently this is not available during rspec testing, because it comes from ApplicationController
      # and there's no controller when helper is run under rspec.
      helper.stub!(:host_locale)
      helper.stub!(:seo_encode){|str| str}
    end

    it 'queries all countries from the database' do
      @visible.should_receive(:find).with(:all, :select => 'DISTINCT country').and_return([])

      helper.active_countries
    end

    it 'maps country abbreviations to their full names' do
      @visible.should_receive(:find).and_return([mock(Location, :country => 'US'), mock(Location, :country => 'GB')])

      helper.active_countries.collect{|c| c.full_name}.sort.should == ['United Kingdom', 'United States']
    end

    it 'returns original country name when it cannot be mapped' do
      @visible.should_receive(:find).and_return([mock(Location, :country => 'Bogus Country')])

      helper.active_countries.collect{|c| c.full_name}.should == ['Bogus Country']
    end

    it 'sorts the results by full name' do
      @visible.should_receive(:find).and_return([mock(Location, :country => 'US'), mock(Location, :country => 'GB'), mock(Location, :country => 'PR')])

      helper.active_countries.collect{|c| c.full_name}.should == ['Puerto Rico', 'United Kingdom', 'United States']
    end

    it 'does not error out with nil countries' do
      @visible.should_receive(:find).and_return([mock(Location, :country => nil), mock(Location, :country => 'GB'), mock(Location, :country => 'PR')])

      lambda{helper.active_countries}.should_not raise_error
    end

    it 'sorts US to the front if requested' do
      @visible.should_receive(:find).and_return([mock(Location, :country => 'US'), mock(Location, :country => 'GB'), mock(Location, :country => 'PR')])

      helper.active_countries(true).collect{|c| c.full_name}.should == ['United States', 'Puerto Rico', 'United Kingdom']
    end
  end

  describe :active_states_for do
    before(:each) do
      @visible = mock('named_scope')
      Location.stub!(:visible).and_return(@visible)

      # Apparently these are not available during rspec testing, because it comes from ApplicationController
      # and there's no controller when helper is run under rspec.
      helper.stub!(:host_locale)
      helper.stub!(:seo_encode){|str| str}
      helper.stub!(:has_provinces?).and_return(true)
    end

    it 'queries all states for the country from the database' do
      @visible.should_receive(:find).with(:all, :select => 'DISTINCT state', :conditions => ['country = ? AND state IS NOT NULL', 'XX']).and_return([])

      helper.active_states_for('XX')
    end

    it 'maps state abbreviations to their full names' do
      @visible.should_receive(:find).and_return([mock(Location, :state => 'TX'), mock(Location, :state => 'CA')])

      helper.active_states_for('US').collect{|c| c.full_name}.sort.should == ['California', 'Texas']
    end

    it 'returns original state name when it cannot be mapped' do
      @visible.should_receive(:find).and_return([mock(Location, :state => 'Bogus State')])

      helper.active_states_for('US').collect{|c| c.full_name}.should == ['Bogus State']
    end

    it 'sorts the results by full name' do
      @visible.should_receive(:find).and_return([mock(Location, :state => 'LA'), mock(Location, :state => 'AK'), mock(Location, :state => 'CA')])

      helper.active_states_for('US').collect{|c| c.full_name}.should == ['Alaska', 'California', 'Louisiana']
    end

    it 'returns an empty array when the country has no provinces' do
      @visible.should_not_receive(:find)
      helper.stub!(:has_provinces?).with('XX').and_return(false)

      helper.active_states_for('XX').should == []
    end
  end

  describe :by_columns do
    it "yields" do
      yielded = false

      helper.by_columns([nil]){yielded = true}

      yielded.should be_true
    end

    it "yields a single column when the count is less than min_column" do
      helper_should_columnize(1, [nil]*6, 8)
    end

    it "yields a single column when the count is equal to min_column" do
      helper_should_columnize(1, [nil]*8, 8)
    end

    it "yields a second column when the count passes min_column" do
      helper_should_columnize(2, [nil]*9, 8)
    end

    it "yields a second column when the count reaches min_column*2" do
      helper_should_columnize(2, [nil]*16, 8)
    end

    it "yields a third column when the count reaches min_column*2 + 1" do
      helper_should_columnize(3, [nil]*(16 + 1), 8)
    end

    it "yields five columns when the count is min_column*5" do
      helper_should_columnize(5, [nil]*(5*8), 8)
    end

    it "still yields five columns when the count is min_column*5 + 1" do
      helper_should_columnize(5, [nil]*(5*8 + 1), 8)
    end

    it "yields six columns when the count is min_column*5 + 1 and max_columns is 6" do
      helper_should_columnize(6, [nil]*(5*4 + 1), 4, 6)
    end

    def helper_should_columnize(num_columns, elements, min_column, max_columns=5)
      count = 0
      element_count = 0

      helper.by_columns(elements, min_column, max_columns) do |yielded_elements|
        count += 1
        element_count += yielded_elements.length
      end

      count.should == num_columns
      element_count.should == elements.length
    end
  end

  describe :sort_locations_by_distance do
    before(:each) do
      @city1 = [mock(Location, :city => 'City1', :state => 'State', :distance => 1, :geocode_precision => :address),
                mock(Location, :city => 'City1', :state => 'State', :distance => 2, :geocode_precision => :city)]
      @city2 = [mock(Location, :city => 'City2', :state => 'State', :distance => 3, :geocode_precision => :address),
                mock(Location, :city => 'City2', :state => 'State', :distance => 4, :geocode_precision => :address)]
      @city3 = [mock(Location, :city => 'City3', :state => 'State', :distance => 1, :geocode_precision => :address),
                mock(Location, :city => 'City3', :state => 'State', :distance => 5, :geocode_precision => :address)]
      @locations = [@city1, @city2, @city3].flatten
    end

    it 'yields a city, state, distance array and a list of locations for each city, state' do
      count = 0

      helper.sort_locations_by_distance(@locations) do |info, group|
        info[0].should =~ %r{City[123]}
        info[1].should == 'State'
        [@city1, @city2, @city3].should include(group)

        count += 1
      end

      count.should == 3
    end

    it 'sorts by distance' do
      count = 0

      helper.sort_locations_by_distance(@locations.sort_by{rand}) do |info, group|
        info[0].should =~ %r{City[123]}
        info[1].should == 'State'
        [@city1, @city2, @city3].should include(group)

        count += 1
      end

      count.should == 3
    end

    it 'provides the distance of any locations with city precision as the distance' do
      helper.sort_locations_by_distance(@city1) do |info, group|
        info[0].should == 'City1'
        info[1].should == 'State'
        info[2].should == 2
      end
    end

    it 'provides the average distance of all locations if none have city precision' do
      helper.sort_locations_by_distance(@city2) do |info, group|
        info[0].should == 'City2'
        info[1].should == 'State'
        info[2].should == 3.5
      end
    end

    it 'sorts the groups by distance of the key' do
      infos = []
      helper.sort_locations_by_distance(@locations) do |info, group|
        infos << info
      end

      infos.should == infos.sort_by{|i| i[2]}
    end
  end

  describe :sort_with_nil do
    it 'sorts elements' do
      helper.sort_with_nil(%w{b c d f e a}).should == %w{a b c d e f}
    end

    it 'sorts nil elements at the end' do
      array = %w{b c d f e a}
      array.insert(3, nil)
      helper.sort_with_nil(array).should == %w{a b c d e f} << nil
    end
  end

  describe :available_translations do
    it 'returns a list of available locales for which we have a translation' do
      helper.available_translations.collect(&:to_s).sort.should == %w{de en ja pt sv}
    end
  end

  describe :language_list do
    before :each do
      helper.stub!(:base_hostname).and_return('example.com')
    end

    it 'has a list' do
      helper.language_list.should have_tag('ul')
    end

    it 'has an item for each available locale we have a translation for' do
      languages = [:en, :de]
      helper.should_receive(:available_translations).and_return(languages)

      helper.language_list.should have_tag('ul') do
        languages.each do |lang|
          with_tag('li a[href=?]', "http://#{lang}.example.com/")
        end
      end
    end
  end

  describe :languages_link do
    before :each do
      helper.stub!(:browser_language).and_return('bl')
      helper.stub!(:t).with(:flag, anything).and_return('bl')
      helper.stub!(:t).with('languages', anything).and_return('translated_language')
    end

    it 'has a link containing the translated word "languages" in the browser language' do
      helper.should_receive(:t).with('languages', :locale => 'bl').and_return('translated_language')
      helper.languages_link.should have_tag('a', /translated_language/)
    end

    it 'links to the languages path' do
      helper.languages_link.should have_tag('a[href=?]', home_path(:page => 'languages'))
    end

    it 'contains a flag image represented by the browser language' do
      helper.should_receive(:t).with(:flag, :locale => 'bl').and_return('bl')
      helper.languages_link.should have_tag('img[src=?]', /.*bl\.png/)
    end

    it 'contains at least one other flag image at the end, not matching the browser language' do
      helper.should_receive(:available_translations).and_return([:bl, :other])
      helper.should_receive(:t).with(:flag, :locale => :other).and_return('other')
      helper.languages_link.should have_tag('img[src=?]', /.*other\.png/)
    end
  end
end
