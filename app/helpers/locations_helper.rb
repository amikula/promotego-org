module LocationsHelper
  PHONE_NUMBER_TYPES = %w{home work cell vmail other}.freeze
  def phone_number_type_select(type, contact_idx, phone_idx)
    no_value = "<option value=''>(none)</option>"
    option_string = PHONE_NUMBER_TYPES.inject(no_value) do |output,this_type|
      selected = (type == this_type ? " selected='selected'" : "")
      output + "<option#{selected}>#{this_type}</option>"
    end

    "<select name='location[contacts][#{contact_idx}][phone][#{phone_idx}][type]'>#{option_string}</select>"
  end

  def visible_affiliations
    if current_user
      affiliations = if current_user.has_role?(:administrator)
                       @location.affiliations.dup
                     else
                       @location.affiliations.select{|a| current_user.administers(a)}
                     end
      Affiliate.find(:all).each do |affiliate|
        if current_user.administers(affiliate) && !affiliations.detect{|a| a.affiliate.name == affiliate.name}
          affiliations << Affiliation.new(:affiliate => affiliate, :location => @location)
        end
      end

      affiliations
    else
      []
    end
  end

  # Returns a hash containing selection lists for each country's provinces, or null for countries
  # with special province 'none'.  Countries with no provinces configured are omitted.  Used in
  # javascript to present a selection of provinces for known countries.
  def state_select_hash
    returning Hash.new do |retval|
      (t :provinces).each_key do |country|
        if !has_provinces?(country)
          retval[country.to_s] = nil
        else
          states_hash = merge_translation_hashes(country, :provinces)
          states_array = states_hash.to_a.map{|a| [a[1],a[0].to_s]}.sort
          states_array.unshift([t('select_state'), '--'])
          retval[country.to_s] = select :location, :state, states_array
        end
      end
    end
  end
end
