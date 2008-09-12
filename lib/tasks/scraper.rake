require 'progressbar'

namespace :scraper do
  task :scrape_clubs => :environment do
    print "Scraping clubs from usgo.org..."
    STDOUT.flush

    type_id = Type.find_by_name("Go Club").id
    count = 0

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

      location.save!

      count += 1
    end

    puts "done!"
    puts "Got #{count} clubs from usgo.org"
  end

  task :geocode_clubs => :environment do
    clubs = Location.find(:all, :conditions => "lat is null or lng is null")
    puts "#{clubs.size} clubs to geocode"

    ProgressBar.with_progress("geocoding", clubs) do |loc|
      loc.geocode
      loc.save!
    end

    puts "Finished!"
  end
end
