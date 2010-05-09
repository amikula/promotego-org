require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  before(:each) do
    @address = "169 N. Berkeley Ave., Pasadena, CA"
    @location = mock_location(:geocode_precision => "address", :geocode_address => "123 Fake Lane, City, State", :lat =>0, :lng => 0)
    controller.stub!(:go_clubs_redirect)
  end

  describe :radius do
    it "assigns radii and types on radius_search" do
      get :radius
      assigns[:radii].should_not be_nil
    end

    describe 'assigns radii according to current distance units' do
      [:mi, :km].each do |units|
        it "(#{units})" do
          subject.should_receive(:distance_units).and_return(units)

          get :radius

          assigns[:radii].should == SearchController::SEARCH_RADII[units]
        end
      end
    end

    [:mi, :km].each do |units|
      it "finds the closest result if no search results are present (#{units})" do
        controller.should_receive(:distance_units).any_number_of_times.and_return(units)
        Location.should_receive(:find).and_return([])
        limit = SearchController::SEARCH_RADII[units].last.send(units).to.miles.to_f

        Location.should_receive(:find_closest).with(:origin => @address,
            :within => limit,
            :conditions => 'lat is not null and lng is not null and hidden = false')

        get :radius, :address => @address, :radius => "5"
      end

      it "provides an appropriate error message when no results are found (#{units})" do
        controller.should_receive(:distance_units).any_number_of_times.and_return(units)
        Location.should_receive(:find).and_return([])
        limit = SearchController::SEARCH_RADII[units].last.send(units).to.miles.to_f
        limit_display = SearchController::SEARCH_RADII[units].last

        controller.should_receive(:t).
          with('no_clubs_matched_limit', :limit => limit_display, :scope => units).
          and_return('translation')

        Location.should_receive(:find_closest).and_return(nil)

        controller.instance_eval{flash.stub!(:sweep)}

        get :radius, :address => @address, :radius => "5"

        flash.now[:error].should == 'translation'
      end
    end

    it "calls find with the results of the find_params method" do
      controller.should_receive(:find_params).and_return(:find_params)
      Location.should_receive(:find).with(:all, :find_params).and_return([@location])

      get :radius, :address => @address, :radius => "5"
    end
  end

  describe :find_params do
    it "returns a Hash" do
      controller.send(:find_params).should be_kind_of(Hash)
    end

    it "contains origin, within, and order params" do
      controller.instance_eval do
        @address = :address
        @radius = :radius
      end

      controller.send(:find_params).should == {:origin => :address, :within => :radius, :order => :distance, :conditions => "hidden = false"}
    end
  end

  def mock_location(options)
    options[:geocode_precision] ||= "city"

    options[:geocode_address] ||= case options[:geocode_precision]
                                  when "address"
                                    "123 Number St., City, State"
                                  when "city"
                                    "City, State"
                                  end

    components = options[:geocode_address].split(/,/)
    if components.size == 3  # address, city, state
      options[:street_address] ||= components[0].strip
      options[:city] ||= components[1].strip
      options[:state] ||= components[2].strip
    elsif components.size == 2  # city, state
      options[:city] ||= components[0].strip
      options[:state] ||= components[1].strip
    else
      raise "Invalid number of components in address"
    end

    options[:distance] ||= "0"

    mock_model(Location, options)
  end
end
