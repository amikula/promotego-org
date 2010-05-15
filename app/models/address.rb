class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true

  def to_s
    returning('') do |retval|
      retval << "#{street_address}, " unless street_address.blank?
      retval << city_state_zip
    end
  end

  def city_state_zip
    components = []
    components << city unless city.blank?

    state_zip = ''
    if state.present?
      state_zip << state
      unless zip_code.blank?
        state_zip << '  '
        state_zip << zip_code.to_s
      end
    else
      state_zip = zip_code.to_s
    end

    components << state_zip unless state_zip.blank?

    components.join(', ')
  end
end
