module LocationsHelper
  # <%= select_tag "location[contacts][][phone[][type]", "<option>home</option><option>work</option><option>cell</option><option>vmail</option><option>other</option>" %>
  PHONE_NUMBER_TYPES = %w{home work cell vmail other}.freeze
  def phone_number_type_select(type, contact_idx, phone_idx)
    option_string = PHONE_NUMBER_TYPES.collect do |this_type|
      selected = (type == this_type ? " selected='selected'" : "")
      "<option#{selected}>#{this_type}</option>"
    end.join('')

    "<select name='location[contacts][#{contact_idx}][phone][#{phone_idx}][type]'>#{option_string}</select>"
  end
end
