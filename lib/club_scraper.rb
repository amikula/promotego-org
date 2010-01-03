require 'open-uri'
require 'hpricot'

class ClubScraper

  US_PHONE_REGEXP = /
    ^           # beginning of string
    \D*         # possible prefix designator for number type
    (\d{3})     # area code is 3 digits (e.g. '800')
    \D*         # optional separator is any number of non-digits
    (\d{3})     # trunk is 3 digits (e.g. '555')
    \D*         # optional separator
    (\d{4})     # rest of number is 4 digits (e.g. '1212')
    \D*         # optional separator
    (\d*)       # extension is optional and can be any number of digits
    $           # end of string
/xi

  OTHER_NUMBER_REGEXP = /^[-0-9+() -]+$/

  def self.is_aga?(element)
    img = element.at('img')
    if (img)
      if (img['src'] =~ /agalogo/)
        true
      else
        logger.warn("is_aga?: Unrecognized image src attribute #{img['src']}")
        false
      end
    else
      unless (element.inner_html.strip == '&nbsp;')
        logger.warn("is_aga?: Unrecognized inner html #{element.inner_html}")
      end

      false
    end
  end

  def self.get_club_name_city_url(element)
    need_name = true
    retval = {}

    state = :find_name
    element.children.each do |child|
      case(state)
      when :find_name
        if (child.text?)
          unless (child.to_s.strip.blank?)
            retval[:name] = child.to_s.strip
            state = :find_br
          end
        elsif (child.elem?)
          if (child.name == 'a')
            retval[:url] = child['href']
            retval[:name] = child.inner_text.strip
            state = :find_br
          elsif (child.name == 'br')
            state = :find_city
          end
        end

      when :find_br
        if (child.elem? && child.name == 'br')
          state = :find_city
        end

      when :find_city
        retval[:city] = child.to_s.strip unless child.to_s.strip.blank?
      end
    end

    if !retval[:name]
      logger.warn("club is missing name: #{element.inspect}")
    elsif !retval[:city]
      logger.warn("club is missing city: #{element.inspect}")
    end

    retval
  end

  # Ok, so it's not thread safe because state is stored at the class level,
  # but that should be ok.  How many threads will be scraping at once?
  cattr_accessor :first_contact
  cattr_accessor :current_contact
  cattr_accessor :contacts

  def self.get_club_contacts(element)

    self.current_contact = {}
    self.contacts = [current_contact]
    self.first_contact = true

    element.children.each do |child|
      if (child.text?)
        text = child.inner_text.strip
        next if text.blank?

        case text
        when /@/
          # email address
          if (text =~ %r{^<a href="mailto:([-0-9a-zA-Z_@.]+)"([a-zA-Z ]+)})
            self.current_contact[:email] = $1
            self.current_contact[:name] = $2
          else
            self.current_contact[:email] = text
          end
          validate_email(text)
        when US_PHONE_REGEXP
          # phone number
          phone_number = {}
          phone_number[:number] = "#{$1}-#{$2}-#{$3}"
          phone_number[:number] += " x#{$4}" if !$4.empty?
          start_of_string = text.match(/^\D*/).to_s #Anything not a number at beginning of string
          end_of_string = text.match(/\D*$/).to_s   #Anything not a number at the end of string
          start_of_string.delete!("^[a-zA-Z]")
          end_of_string.delete!("^[a-zA-Z")
          #phone_number[:type] = $1 if !$1.nil?
          #phone_number[:type] ||= $6 if !$6.nil?
          phone_number[:type] = start_of_string if !start_of_string.empty?
          phone_number[:type] ||= end_of_string if !end_of_string.empty?
          current_contact[:phone] ||= []
          current_contact[:phone] << phone_number
        when OTHER_NUMBER_REGEXP
          # international number
          current_contact[:phone] ||= []
          current_contact[:phone] << {:number => text}
        else
          # name
          new_contact

          validate_name(text)

          self.current_contact[:name] = text
        end
      else
        next if child.bogusetag?

        case child.name
        when 'a'
          # hyperlinked name
          self.new_contact

          if child[:href] =~ /:/
            email = child[:href].split(/:/)[1]
          elsif child[:href] =~ /^mailto(.*)$/
            email = $1
          else
            email = child[:href]
          end

          email.strip!
          validate_email(email)

          name = child.inner_text.strip
          validate_name(name)
          self.current_contact[:email] = email
          self.current_contact[:name] = name
        when 'br'
          next
        end
      end
    end

    # Remove empty hash if present
    self.contacts = [] if self.contacts[0].empty?

    contacts
  end

  def self.get_club_info(element)
    info = element.to_plain_text.gsub(/\s*\n+\s*/, "<br>")
    address = nil
    element.children.each do |child|
      if (child.text?)
        tmp = child.inner_text.strip
        if !address && tmp =~ /([0-9]+[ \t]+[a-z0-9\. \t]+([ \t]+(lane|ln|street|st|avenue|ave|blvd|bl|boulevard|road|rd|place|pl|square|sq|court|ct|drive|dr|highway|hwy|parkway|pkwy))?\.?)/i
          address = $1

          # Handle case of matching time string
          address = nil if address =~ /^[0-9]+ (am|pm)$/i
        end
      end
    end

    retval = {:info => info}
    retval[:address] = address if address

    retval
  end

  def self.get_club_table(element, state=:find_anchor)
    element.search('*').each do |child|
      if child.elem?
        case state
        when :find_anchor
          if child.name == 'a' && child[:name] == 'listing'
            state = :find_table
          end
        when :find_table
          if child.name == 'table'
            return child
          end
        end
      end
    end
  end

  def self.get_club_from_row(row)
    returning({}) do |club|
      cells = row.search('td')

      club[:is_aga?] = is_aga?(cells[0])
      add_hash(club, get_club_name_city_url(cells[1]))
      club[:contacts] = get_club_contacts(cells[2])
      add_hash(club, get_club_info(cells[3]))
    end
  end

  def self.get_state_from_row(row)
    returning({}) do |retval|
      cell = row.at('td')
      state = cell.inner_text.strip
      if (state.blank? || state == "Overseas")
        state = "XX"
      end

      retval[:state] = state
    end
  end

  def self.is_state_row?(row)
    row[:bgcolor] == 'silver'
  end

  def self.process_table(table)
    first_row = true
    state = {:state => "XX"}
    table.search('/tr').each do |row|
      # Skip the header row
      if first_row
        first_row = false
        next
      end

      if is_state_row?(row)
        state = get_state_from_row(row)
      else
        club = get_club_from_row(row)

        yield add_hash(club, state)
      end
    end
  end

  def self.get_clubs_from_url(url, &block)
    table = get_table_from_url(url)

    process_table(table, &block)
  end

  def self.get_table_from_url(url)
    page = get_url(url)

    get_club_table(page)
  end

  private
  def self.get_url(url)
    open(url) do |file|
      Hpricot(file)
    end
  end

  def self.add_hash(original, new)
    new.each_pair do |key, value|
      original[key] = value
    end

    original
  end

  def self.validate_name(name)
    logger.warn("Unexpected name format: #{name}") unless name =~ /^[a-z\s]+$/i
  end

  def self.validate_email(email)
    logger.warn("Bad email address format: #{email}") unless email =~ /[a-z0-9_.]+@[a-z0-9_.]+/i
  end

  def self.new_contact
    unless first_contact
      self.current_contact = {}
      self.contacts << self.current_contact
    end

    self.first_contact = false
  end

  def self.logger
    RAILS_DEFAULT_LOGGER
  end
end
