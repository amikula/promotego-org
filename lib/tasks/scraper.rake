require 'progressbar'

namespace :scraper do
  desc 'Scrape clubs from the AGA web site'
  task :scrape_clubs => :environment do
    print 'Scraping clubs from usgo.org...'
    STDOUT.flush

    type_id = Type.find_by_name('Go Club').id
    count = 0

    ClubScraper.get_clubs_from_url('http://usgo.org/cgi-bin/chapters.cgi?state=ALL') do |club|
      location = Location.new

      location.type_id = type_id
      location.name = club[:name]
      location.street_address = club[:address]
      location.city = club[:city]
      #Set the country - default country is United States if none is set.
      location.country = club[:country] || 'US'
      #Set the state by two-letter code, or whatever the scraper gives us if we can't find it.
      location.state = STATE_TO_ABBREV[location.country][club[:state]] || club[:state]
      if club[:phone]
        location.phone_number = club[:phone][0][:number]
      end
      location.contacts = club[:contacts]
      location.url = club[:url]
      location.description = club[:info]
      location.hidden = false
      location.save!
      #If it is an AGA club, we create the affiliation, which requires some data massaging.
      if club[:is_aga?]
        aga = Affiliate.find_by_name('AGA')
        begin
          name = location.contacts[0][:name]
        rescue NoMethodError
          name = nil
        end
        
        begin
          email = location.contacts[0][:email]
        rescue NoMethodError
          email = nil
        end

        begin
          phone = location.contacts[0][:phone][0][:number]
        rescue NoMethodError
          phone = nil
        end
        affiliation = Affiliation.new(:location => location, :affiliate => aga, :expires => Time.now + 1.year,
                                 :contact_name => name, :contact_address => location.street_address,
                                 :contact_city => location.city, :contact_state => location.state,
                                 :contact_zip => location.zip_code, :contact_telephone => phone,
                                 :contact_email => email, :foreign_key => location.id)
        affiliation.save!
      end

      count += 1
    end

    puts 'done!'
    puts "Got #{count} clubs from usgo.org"
  end

  desc 'Load clubs from MDB file'
  task :load_mdb => :environment do
    CsvLoader.load_mdb('db/chapclub.csv')
  end

  desc 'Geocode clubs in the db without a lat or lng'
  task :geocode_clubs => :environment do
    clubs = Location.find(:all, :conditions => 'lat is null or lng is null')
    puts "#{clubs.size} clubs to geocode"
    failed = 0

    ProgressBar.with_progress('geocoding', clubs) do |loc|
      loc.geocode
      failed += 1 if loc.lat == nil || loc.lng == nil
      loc.save!
    end

    puts 'Finished!'
    puts "#{failed} geocode failures"
  end
end
