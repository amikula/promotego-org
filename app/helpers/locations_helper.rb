module LocationsHelper
  # <%= select_tag "location[contacts][][phone[][type]", "<option>home</option><option>work</option><option>cell</option><option>vmail</option><option>other</option>" %>
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
end
