class Location < ActiveRecord::Base
  acts_as_mappable
  belongs_to :type

  # Geocode the address represented by this location, storing the result in
  # lat and lng and returning the geocode object if it was successful, or nil
  # otherwise.
  def geocode
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(geocode_address)
    if geo.success
      self.lat, self.lng = geo.lat, geo.lng
      return geo
    else
      errors.add_to_base("Could not geocode address")
      return nil
    end
  end

  def geocode_address
    unless city.blank? || state.blank?
      city_state_zip = city + ", " + state
    end

    unless zip_code.blank?
      city_state_zip += " " unless city_state_zip.blank?
      city_state_zip += zip_code
    end

    if city_state_zip.blank?
      errors.add_to_base("Must provide at least either city and state or zip code")
      return nil
    end

    if street_address.blank?
      geo_address = city_state_zip
    else
      geo_address = street_address + ", " + city_state_zip
    end

    return geo_address
  end

end
