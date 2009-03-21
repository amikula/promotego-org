module LocationsHelper
  # <%= select_tag "location[contacts][][phone[][type]", "<option>home</option><option>work</option><option>cell</option><option>vmail</option><option>other</option>" %>
  PHONE_NUMBER_TYPES = %w{home work cell vmail other}.freeze
  def phone_number_type_select(type, contact_idx, phone_idx)
    no_value = "<option value=''>(none)</option>"
    option_string = PHONE_NUMBER_TYPES.inject(no_value) do |output,this_type|
      selected = (type == this_type ? " selected='selected'" : "")
      output + "<option#{selected}>#{this_type}</option>"
    end

    "<select name='location[contacts][#{contact_idx}][phone][#{phone_idx}][type]'>#{option_string}</select>"
  end

  def visible_affiliations
    if current_user
      affiliations = if current_user.has_role?(:administrator)
                       @location.affiliations.dup
                     else
                       @location.affiliations.select{|a| current_user.administers(a)}
                     end
      Affiliate.find(:all).each do |affiliate|
        if current_user.administers(affiliate) && !affiliations.detect{|a| a.affiliate.name == affiliate.name}
          affiliations << Affiliation.new(:affiliate => affiliate, :location => @location)
        end
      end

      affiliations
    else
      []
    end
  end

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

  def create_map(lat, lng, zoom)
    map = GMap.new("map_div")
    map.control_init(:large_map => true,:map_type => true)

    unless zoom.class == Integer
      zoom = ZOOM[zoom || 'unknown']
    end

    map.center_zoom_init([lat,lng], zoom)

    map
  end

  def pushpin_for_club(location, options={}, map=@map)
    info_window = render_to_string :partial => "gmap_info_window",
      :locals => {:location => location, :options => options}
    info_window.gsub!(/\n/, '')
    info_window.gsub!('"', "'")

    club = GMarker.new([location.lat,location.lng], :info_window => info_window)
    map.record_global_init(club.declare("club#{location.id}"))
    map.overlay_init(club)
    map.record_init("club#{location.id}.openInfoWindowHtml(\"#{club.info_window}\");\n") if options[:show_info_window]
  end
end
