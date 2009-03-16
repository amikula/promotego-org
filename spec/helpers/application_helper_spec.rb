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
end
