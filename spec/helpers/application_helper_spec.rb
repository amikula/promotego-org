require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe :active_countries do
    before(:each) do
      @visible = mock('named_scope')
      Location.stub!(:visible).and_return(@visible)
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
end
