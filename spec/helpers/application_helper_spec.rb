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
      @visible.should_receive(:find).with(:all, :select => 'DISTINCT state', :conditions => ['country = ?', 'XX']).and_return([])

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
end
