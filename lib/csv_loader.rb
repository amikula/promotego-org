require 'fastercsv'
require 'hpricot'

class CsvLoader
  def self.club_from(row)
    url = row['Web Site'].blank? ? nil : 'http://' + row['Web Site']
    club_info = ClubScraper.get_club_info(Hpricot(row['Meeting_HTML']))
    expire = Date.parse(row['Expire']) unless row['Expire'].blank?
    if expire
      if expire.year < 50
        expire = Date.civil(expire.year+2000, expire.month, expire.day)
      elsif expire.year < 100
        expire = Date.civil(expire.year+1900, expire.month, expire.day)
      end
    end

    club = Location.new(:name => row['Name'], :city => row['Meeting_City'], :state => row['State'],
                 :url => url, :description => row['Meeting_HTML'].gsub("\r\n", ''),
                 :contacts => ClubScraper.get_club_contacts(Hpricot(row['Contact_HTML'])),
                 :street_address => club_info[:address], :hidden => row['DO_NOT_DISPLAY'].to_i)

    if expire
      aga = Affiliate.find_by_name('AGA')
      affiliation = Affiliation.new(:location => club, :affiliate => aga, :expires => expire,
                                    :contact_name => row['Contact'], :contact_address => row['Address'],
                                    :contact_city => row['City'], :contact_state => row['State'],
                                    :contact_zip => row['ZIP'], :contact_telephone => row['Telephone'],
                                    :contact_email => row['Email'], :foreign_key => row['chapter'])
      club.affiliations << affiliation
    end

    club
  end

  def self.load_mdb(filename)
    aga = Affiliate.find_by_name('AGA') || Affiliate.create!(:name => 'AGA', :full_name => 'American Go Association')
    type = Type.find_by_name("Go Club")

    FasterCSV.foreach(filename, :headers => true) do |row|
      club = club_from(row)
      club.type_id = type.id
      club.save!
    end
  end
end
