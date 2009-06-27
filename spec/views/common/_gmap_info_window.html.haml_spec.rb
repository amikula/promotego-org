require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/common/_gmap_info_window" do
  it 'does not show driving directions if street address is missing' do
    location = stub_model(Location, :geocode_precision => 'address', :street_address => '')

    render :partial => 'common/gmap_info_window', :locals => {:options => {}, :location => location}

    response.should_not have_tag('a', 'Directions')
  end

  it 'shows driving directions if street address is present' do
    location = stub_model(Location, :geocode_precision => 'address', :street_address => 'address')

    render :partial => 'common/gmap_info_window', :locals => {:options => {}, :location => location}

    response.should have_tag('a', 'Directions')
  end
end
