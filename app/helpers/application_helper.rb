# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_standard_flashes(message = 'There were some problems with your submission:')
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
    elsif flash[:error]
      level = 'error'
      if flash[:error].instance_of? ActiveRecord::Errors
        flash_to_display = message
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = flash[:error]
      end
    else
      return
    end
    content_tag 'div', flash_to_display, :class => "flash #{level}"
  end

  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end

  Abbreviable = Struct.new(:full_name, :abbrev)

  def active_countries(us_first=false)
    Location.visible.find(:all, :select => 'DISTINCT country').collect do |l|
      Abbreviable.new(COUNTRY_FROM_ABBREV[l.country] || l.country, l.country)
    end.sort_by{|c| (us_first && c.abbrev == 'US') ? 'AAAAAAAA' : c.full_name}
  end

  def active_states_for(cntry)
    Location.visible.find(:all, :select => 'DISTINCT state', :conditions => ['country = ?', cntry]).collect do |l|
      full_state_name = (STATE_FROM_ABBREV[cntry] && STATE_FROM_ABBREV[cntry][l.state]) || l.state
      Abbreviable.new(full_state_name, l.state)
    end.sort_by{|s| s.full_name}
  end

  def by_columns(collection, min_column=8, max_columns=5)
    elems_per_slice = [min_column, (collection.length/max_columns.to_f).ceil].max

    collection.each_slice(elems_per_slice) do |slice|
      yield slice
    end
  end
end
