# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_standard_flashes(message=t('default_submission_error'))
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

  Abbreviable = Struct.new(:full_name, :url_name, :abbrev)

  def active_countries(us_first=false)
    Location.visible.find(:all, :select => 'DISTINCT country').collect do |l|
      if l.country.blank?
        Abbreviable.new('None', 'None', 'None')
      else
        country_name = I18n.translate(l.country, :scope => 'countries', :default => l.country)
        country_url_fragment = seo_encode(I18n.translate(l.country, :scope => 'countries', :locale => host_locale, :default => country_name))
        Abbreviable.new(country_name, country_url_fragment, l.country)
      end
    end.sort_by{|c| (us_first && c.abbrev == 'US') ? 'AAAAAAAA' : c.full_name}
  end

  def active_states_for(cntry)
    return [] unless has_provinces?(cntry)

    Location.visible.find(:all, :select => 'DISTINCT state', :conditions => ['country = ? AND state IS NOT NULL', cntry]).collect do |l|
      full_state_name = t(l.state, :scope => [:provinces, cntry], :default => l.state)
      full_state_url_fragment = seo_encode t(l.state, :scope => [:provinces, cntry], :locale => host_locale, :default => l.state)
      Abbreviable.new(full_state_name, full_state_url_fragment, l.state)
    end.sort_by{|s| s.full_name}
  end

  def by_columns(collection, min_column=8, max_columns=5)
    elems_per_slice = [min_column, (collection.length/max_columns.to_f).ceil].max

    collection.each_slice(elems_per_slice) do |slice|
      yield slice
    end
  end

  def sort_locations_by_distance(locations)
    by_cities = locations.group_by{|l| [l.city, l.state]}
    with_distance = []

    by_cities.keys.each do |key|
      group = by_cities[key]
      distance_location = group.detect{|l| l.distance if l.geocode_precision == :city}

      if distance_location
        distance = distance_location.distance
      else
        sum = group.inject(0){|sum, cur| sum+cur.distance.to_f}
        distance = sum/group.size.to_f
      end

      with_distance << [key + [distance], group]
    end

    with_distance.sort_by{|k| k[0][2]}.each do |ary|
      yield ary[0], ary[1].sort_by{|l| l.distance}
    end
  end

  def sort_with_nil(elements)
    elements.sort do |a,b|
      if a.nil?
        1
      elsif b.nil?
        -1
      else
        a <=> b
      end
    end
  end

  def available_translations
    I18n.available_locales.inject([]) do |avail, l|
      avail << l if I18n.t(:translated, :locale => l).locale == l
      avail
    end
  end

  def language_list
    content_tag :ul, :class => 'submenu' do
      available_translations.inject("") do |ret, lang|
        ret << content_tag(:li) do
                 language_native = t(lang, :scope => :language_names, :locale => lang)
                 language = t(lang, :scope => :language_names)

                 language_display = language_native
                 language_display << " (#{language})" unless language_display == language
                 flag = t(:flag, :locale => lang)
                 content_tag(:a, image_tag("/images/flags/#{flag}.png") + language_display, :href => "http://#{lang}.#{base_hostname}/")
               end
      end
    end
  end

  def languages_link
    flag = t(:flag, :locale => browser_language)
    flag_image = image_tag("/images/flags/#{flag}.png")

    other_languages = available_translations.dup
    other_languages.delete(browser_language[0..1].to_sym) if browser_language

    other_flag = t(:flag, :locale => other_languages[rand(other_languages.length)])
    other_flag_image = image_tag("/images/flags/#{other_flag}.png")

    languages_text = t('languages', :locale => browser_language)

    link_to "#{flag_image}&nbsp;#{languages_text}&nbsp;#{other_flag_image}", home_path(:page => 'languages')
  end
end
