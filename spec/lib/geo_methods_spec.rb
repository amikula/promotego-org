require File.dirname(__FILE__) + '/../spec_helper'

describe GeoMethods do
  class TestObject
    include GeoMethods
  end

  def subject
    @subject ||= TestObject.new
  end

  describe :create_map do
    before :each do
      @gmap = mock(GMap)
      @gmap.stub!(:control_init)
      @gmap.stub!(:center_zoom_init)
      @gmap.stub!(:center_zoom_on_bounds_init)
      GMap.stub!(:new).and_return(@gmap)
    end

    it "should return a map when an object with a valid lat and lng are passed" do
      GMap.should_receive(:new).with("map_div").and_return(@gmap)

      subject.create_map(mock_model(Location, :lat => 0, :lng => 0, :geocode_precision => 'address')).should == @gmap
    end

    it "should return nil when an object without a valid lat and lng are passed" do
      GMap.should_not_receive(:new)

      subject.create_map(mock_model(Location, :lat => nil, :lng => nil)).should be_nil
    end

    it "should return a map when an array of objects with at least one valid lat and lng are passed" do
      GMap.should_receive(:new).with("map_div").and_return(@gmap)

      subject.create_map([stub_model(Location, :lat => 0, :lng => 0), stub_model(Location, :lat => 0, :lng => 0), stub_model(Location, :lat => 0, :lng => 0)]).should == @gmap
    end

    it "should return nil when an array of objects without at least one valid lat and lng are passed" do
      GMap.should_not_receive(:new)

      subject.create_map([stub_model(Location, :lat => nil, :lng => nil), stub_model(Location, :lat => nil, :lng => nil), stub_model(Location, :lat => nil, :lng => nil)]).should == nil
    end

    it "initializes the map" do
      @gmap.should_receive(:control_init).with(:large_map => true, :map_type => true)

      subject.create_map(mock_model(Location, :lat => 0, :lng => 0, :geocode_precision => 'address')).should == @gmap
    end

    it "should conter the map on the lat and lng if a Location is passed" do
      @gmap.should_receive(:center_zoom_init).with([:lat, :lng], 6)

      subject.create_map(mock_model(Location, :lat => :lat, :lng => :lng, :geocode_precision => 6)).should == @gmap
    end

    it "should map strings to zoom number" do
      @gmap.should_receive(:center_zoom_init).with([:lat, :lng], 14)

      subject.create_map(mock_model(Location, :lat => :lat, :lng => :lng, :geocode_precision => 'street')).should == @gmap
    end

    it "creates bounds from arrays passed in" do
      locations = [mock_model(Location, :lat => 0, :lng => 0), stub_model(Location, :lat => 0, :lng => 0), stub_model(Location, :lat => 0, :lng => 0)]
      subject.should_receive(:get_bounds_for).with(locations, 0).and_return(:bounds)
      @gmap.should_receive(:center_zoom_on_bounds_init).with(:bounds)

      subject.create_map(locations).should == @gmap
    end
  end
end
