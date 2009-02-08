require 'fastercsv'
require 'hpricot'

class CsvLoader
  def self.club_from(row)
    url = row['Web Site'].blank? ? nil : 'http://' + row['Web Site']
    club_info = ClubScraper.get_club_info(Hpricot(row['Meeting_HTML']))
    expire = Date.parse(row['Expire']) unless row['Expire'].blank?
    if !expire
      expire = Date.new(0)
    elsif expire.year < 50
      expire += 2000.years
    elsif expire.year < 100
      expire += 1900.years
    end
    is_aga = Time.now < expire
    Location.new(:name => row['Name'], :city => row['Meeting_City'], :state => row['State'],
                 :url => url, :description => row['Meeting_HTML'].gsub("\r\n", ''),
                 :is_aga => is_aga,
                 :contacts => ClubScraper.get_club_contacts(Hpricot(row['Contact_HTML'])),
                 :street_address => club_info[:address])
  end

  def self.load_mdb(filename)
    type = Type.find_by_name("Go Club")

    FasterCSV.foreach(filename, :headers => true) do |row|
      club = club_from(row)
      club.type_id = type.id
      club.save!
    end
  end
end
