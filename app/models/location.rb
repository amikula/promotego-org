class Location < ActiveRecord::Base
  class LocationHeader < Struct.new(:geocode_address, :geocode_precision, :distance); end

  acts_as_mappable
  belongs_to :user
  belongs_to :source
  has_many :affiliations, :dependent => :destroy
  has_many :slug_redirects, :dependent => :destroy
  has_many :affiliates, :through => :affiliations

  serialize :contacts

  attr_protected :user

  named_scope :visible, :conditions => {:hidden => false}
  named_scope :hidden, :conditions => {:hidden => true}

  validates_presence_of :name, :city, :country, :description

  def self.valid_options
    {
      :name => "LocationName",
      :street_address => "Street Address",
      :city => "Anytown",
      :state => "TX",
      :country => "US",
      :zip_code => "00000",
      :description => "description",
      :contacts => [],
      :hours => "",
      :url => 'http://domain.com',
      :hidden => false,
      :geocode_precision => "address"
    }
  end

  def to_param
    slug
  end

  def before_save
    clean_empty_contacts
    if self.slug.blank? || self.slug_should_change?
      self.slug = first_available_slug(self.name.sluggify)
    end

    if self.slug_changed?
      old_slug = changes['slug'][0]
      if old_slug
        SlugRedirect.destroy_all(['slug = ?', self.slug])
        slug_redirect = SlugRedirect.new(:slug => old_slug)
        slug_redirects << slug_redirect
      end
    end
  end

  def slug_should_change?
    self.name_changed? && self.changes['name'].map(&:sluggify).uniq.length > 1
  end

  def user=(new_user)
    raise SecurityError.new("Must call change_user on objects already in the database") unless new_record?

    self.user_id = new_user.id
  end

  def user_id=(new_user_id)
    raise SecurityError.new("Must call change_user on objects already in the database") unless new_record?

    write_attribute(:user_id, new_user_id)
  end


  # Geocode the address represented by this location, storing the result in
  # lat and lng and returning the geocode object if it was successful, or nil
  # otherwise.
  def geocode
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(geocode_address)
    if geo.success
      self.lat, self.lng = geo.lat, geo.lng
      self.geocode_precision = geo.precision
      return self
    else
      errors.add_to_base("Could not geocode address")
      return nil
    end
  end

  def geocode_address
    element = []

    unless street_address.blank?
      element << street_address
    end

    unless city.blank?
      element << city
    end

    unless state.blank? && zip_code.blank?
      state_zip = state.nil? ? '' : state.clone
      if state_zip.blank?
        state_zip = zip_code.clone
      elsif !zip_code.blank?
        state_zip << " "
        state_zip << zip_code
      end

      element << state_zip unless state_zip.blank?
    end

    unless country.blank?
      element << country
    end

    return element.join(", ")
  end

  def change_user(new_user, administrator)
    if(administrator.has_role?(:administrator))
      case new_user
      when User:
        write_attribute(:user, new_user)
      when Fixnum:
        write_attribute(:user_id, new_user)
      when String:
        write_attribute(:user_id, new_user.to_d)
      end
    else
      raise SecurityError.new("Only administrators may change owning user of a location")
    end
  end

  def city_state_zip
    components = []
    components << city unless city.blank?

    state_zip = ''
    unless state.blank?
      state_zip << state
      unless zip_code.blank?
        state_zip << ' '
        state_zip << zip_code
      end
    else
      state_zip = zip_code
    end

    components << state_zip unless state_zip.blank?

    components.join(', ')
  end

  def driving_directions?
    geocode_precision == 'address' && !street_address.blank?
  end

private
  # Returns the first available slug that doesn't conflict with a known slug
  def first_available_slug(slug)
    slugs = Location.find(:all, :conditions => "slug LIKE '#{slug}%'", :select => 'slug').map(&:slug)
    redirects = SlugRedirect.find(:all, :conditions => "slug LIKE '#{slug}%'")

    if slugs.include?(slug) || detect_redirect_conflict(slug, redirects)
      i = 2
      while(slugs.include?(candidate = "#{slug}-#{i}") || detect_redirect_conflict(candidate, redirects))
        i += 1
      end

      candidate
    else
      slug
    end
  end

  def detect_redirect_conflict(slug, redirects)
    redirect = redirects.detect{|r| r.slug == slug}

    if redirect.blank? || redirect.location_id == self.id
      nil
    else
      redirect
    end
  end

  # Fires before saving a location and updates slug
  def clean_empty_contacts
    return if contacts.nil?

    contacts.delete_if do |contact|
      clean_blanks(contact)

      contact.blank? || has_only_blank_phones(contact)
    end

    self.contacts = nil if contacts.blank?
  end

  def has_only_blank_phones(contact)
    phone_array = contact[:phone] || contact["phone"]
    unless phone_array.nil?
      phone_array.delete_if do |phone|
        clean_blanks(phone)

        phone.blank? || phone.keys.map(&:to_sym) == [:type]
      end
    end

    if contact.keys.map(&:to_sym) == [:phone]
      return phone_array.blank?
    else
      return false
    end
  end

  def clean_blanks(hash)
    hash.delete_if{|key,value| value.blank?}
  end

protected
  def validate
    if country == '--'
      errors.add(:country, 'must be selected')
    elsif state == '--'
      errors.add(:state, 'must be selected')
    elsif abbrevs=STATE_FROM_ABBREV[country]
      unless abbrevs[state] || STATE_TO_ABBREV[country][state]
        errors.add(:state, "'#{state}' is not a valid state")
      end
    end
  end
end
