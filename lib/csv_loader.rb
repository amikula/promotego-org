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
                 :street_address => club_info[:address], :hidden => row['DO_NOT_DISPLAY'].to_i,
                 :country => 'US')

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

    FasterCSV.foreach(filename, :headers => true) do |row|
      club = club_from(row)
      save_or_update_club(club)
    end
  end

  OMIT_ATTRIBUTES = %w{country state id slug created_at updated_at lng lat user_id geocode_precision hidden hours}
  def self.match_clubs(club1, club2)
    total_length = 0
    total_distance = 0

    club1.attributes.keys.each do |attribute|
      next if OMIT_ATTRIBUTES.include?(attribute)

      c1_val = club1.attributes[attribute] || ""
      c2_val = club2.attributes[attribute] || ""

      next if c1_val.blank? || c2_val.blank?

      total_length += c1_val.length
      total_distance += Amatch::Levenshtein.new(c1_val.to_s).match(c2_val.to_s)
    end

    match_score = total_distance.to_f / total_length.to_f

    match_score
  end

  def self.save_or_update_club(club)
    unless club.affiliations.blank?
      club_aff = club.affiliations.first
      affiliation = Affiliation.find(:first, :conditions => ['affiliate_id = ? and foreign_key = ?',
                                     club_aff.affiliate_id, club_aff.foreign_key], :include => :location)
    end

    if affiliation
      update_club!(affiliation.location, club)
    elsif(urlmatch = match_url(club.url))
      unless club.name.sluggify == urlmatch.slug
        puts "matched club #{club.name.sluggify} with db club #{urlmatch.slug} by url"
      end
      update_club!(urlmatch, club)
    else
      db_clubs = Location.find(:all, :conditions => ['slug LIKE ?', "#{club.name.sluggify}%"])
      saved = false
      db_clubs.each do |db_club|
        next unless db_club.slug =~ %r{^#{club.name.sluggify}(-[0-9]+)?$}

        if (score = match_clubs(club, db_club)) <= 0.4
          puts "matched clubs with score #{score}: #{db_club.slug}" unless score == 0
          update_club!(db_club, club)
          saved = true
          break
        else
          puts "mismatched clubs, score #{score}: #{club.name.sluggify}, db: #{db_club.slug}"
        end
      end

      unless saved
        club.save(false) || raise("Problem saving club #{club.name}")
        puts "Saved new club #{club.slug}"
      end
    end
  end

  def self.update_club!(db_club, new_club)
    raise "Assertion failure: new_club should have no more than 1 affiliation" unless new_club.affiliations.length <= 1
    if new_club.affiliations.length > 0
      affiliation = db_club.affiliations.detect{|aff| aff.affiliate_id == new_club.affiliations[0].affiliate_id}
    end

    if affiliation
      new_attributes = new_club.affiliations[0].attributes.reject{|k,v| v.nil?}
      if affiliation.expires < new_club.affiliations[0].expires
        puts "updating expiration for #{db_club.slug}"
      else
        new_attributes.delete('expires')
      end

      affiliation.attributes = new_attributes
      affiliation.save(false) || raise("Error updating affiliation #{affiliation.id}")
    end

    db_club.attributes = filter_attributes(new_club.attributes)
    db_club.save(false) || raise("Error updating attributes for club #{club.name}")
  end

  URL_EXCEPTIONS = %w{
    http://www.erols.com/jgoon/links-go.htm
  }

  def self.match_url(url)
    unless url.blank? || URL_EXCEPTIONS.include?(url)
      Location.find(:first, :conditions => ['url = ?', url])
    end
  end

  def self.filter_attributes(attributes)
    attributes.reject{|k,v| OMIT_ATTRIBUTES.include?(k)}
  end
end
