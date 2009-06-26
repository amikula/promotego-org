module Importers
  module BgaImporter
    extend self

    def load_data(data)
      doc = Nokogiri::XML.parse(data)
      doc.root.add_namespace('bga', 'http://www.britgo.org/clublist.dtd')

      doc.xpath('//bga:club').each do |club|
        location = load_club(club)
        location.save(false)
      end
    end

    def load_club(node)
      location = Location.new

      {:name => 'name',
       :url => 'web-site',
       :description => 'comment'}.each_pair do |attr, bga_attr|
        assign_attr(location, node, attr, bga_attr)
      end

      club_locations = node.xpath('./bga:meeting/bga:location')

      club_location = club_locations.detect{|loc| loc['lon'] && loc['lat']}

      if club_location
        location.lng = club_location['lon'].to_f if club_location['lon']
        location.lat = club_location['lat'].to_f if club_location['lat']
        location.geocode_precision = 'address'
        if (pcode = club_location.xpath('./bga:pcode').first)
          location.zip_code = pcode.content
        end
      else
        location.lng = node['lon'].to_f if node['lon']
        location.lat = node['lat'].to_f if node['lat']
        location.geocode_precision = 'city'
      end

      location.contacts = node.xpath('./bga:contact').collect{|c| get_contact(c)}

      location.country = 'GB'
      location.hidden = false

      location
    end

    def assign_attr(location, source_node, attr, bga_attr)
      bga_node = source_node.xpath("./bga:#{bga_attr}").first

      if bga_node && !bga_node.content.blank?
        location.send("#{attr}=", bga_node.content)
      end
    end

    def get_contact(contact)
      returning Hash.new do |retval|
        retval[:name] = read_value('./bga:person', contact)
        retval[:email] = read_value('./bga:email', contact)
        if(tels=contact.xpath('./bga:tel'))
          retval[:phone] = []
          tels.each do |tel|
            phone_number = {}
            phone_number[:number] = tel.content
            phone_number[:type] = tel['type']
            retval[:phone] << phone_number
          end
        end
      end
    end

    def read_value(path, node)
      val_node = node.xpath(path).first

      val_node.content if val_node
    end
  end
end
