module GeoMethods
  ZOOM = {
    "unknown" => 6,
    "country" => 3,
    "state" => 6,
    "city" => 12,
    "zip" => 13,
    "zip+4" => 14,
    "street" => 14,
    "address" => 15
  }

  def create_map(mappable, min_bounds=0)
    case mappable
    when Location
      return nil if mappable.lng.blank? && mappable.lat.blank?
    when Array
      return nil if mappable.detect{|l| !l.lng.nil? && !l.lat.nil?}.blank?
    end

    map = GMap.new("map_div")
    map.control_init(:large_map => true,:map_type => true)

    case mappable
    when Location
      zoom = mappable.geocode_precision
      unless zoom.is_a? Integer
        zoom = ZOOM[zoom || 'unknown']
      end

      map.center_zoom_init([mappable.lat,mappable.lng], zoom)
    when Array
      bounds = get_bounds_for(mappable, min_bounds)
      map.center_zoom_on_bounds_init(bounds)
    end

    map
  end

  def pushpin_for_club(location, options={}, map=@map)
    info_window = render_to_string :partial => "common/gmap_info_window",
      :locals => {:location => location, :options => options}
    info_window.gsub!(/\n/, '')
    info_window.gsub!('"', "'")

    club = GMarker.new([location.lat,location.lng], :info_window => info_window)
    map.record_global_init(club.declare("club#{location.id}"))
    map.overlay_init(club)
    map.record_init("club#{location.id}.openInfoWindowHtml(\"#{club.info_window}\");\n") if options[:show_info_window]
  end

  def get_bounds_for(locations, minimum_pad=0)
    lats = locations.collect{|l| l.lat}.compact
    lngs = locations.collect{|l| l.lng}.compact

    unless lats.blank? || lngs.blank?
      lat_max = lats.max
      lat_min = lats.min
      lng_max = lngs.max
      lng_min = lngs.min

      pad = [(lat_max-lat_min)/7.0, (lng_max-lng_min)/10.0, minimum_pad].max

      [[lat_min-pad, lng_min-pad], [lat_max+pad, lng_max+pad]]
    end
  end

  def geocode(geocode_address)
    GeoKit::Geocoders::MultiGeocoder.geocode(geocode_address)
  end
end
