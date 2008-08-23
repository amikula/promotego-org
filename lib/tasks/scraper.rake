namespace :scraper do
  task :scrape_clubs => :environment do
    type_id = Type.find_by_name("Go Club").id

    ClubScraper.get_clubs_from_url("http://usgo.org/cgi-bin/chapters.cgi?state=ALL") do |club|
      location = Location.new

      location.type_id = type_id
      location.name = club[:name]
      location.street_address = club[:address]
      location.city = club[:city]
      location.state = club[:state]
      if club[:phone]
        location.phone_number = club[:phone][0][:number]
      end
      location.contacts = club[:contacts]
      location.url = club[:url]
      location.description = club[:info]
      location.is_aga = club[:is_aga?]

      location.geocode
      
      location.save!
    end
  end
end
