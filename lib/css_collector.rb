require 'set'

class CssCollector
  def initialize(*properties)
    @values = Hash.new{|hash,key| hash[key] = []}
    @property_set = Set.new
    @collected_properties = Set.new
    properties.each do |property|
      @property_set.add(property.to_s)
    end
  end

  def collect_attribute(css)
    # ignore CSS comments
    css.gsub!(%r{/\*.*?\*/}m, '')

    # strip !important
    css.gsub!(/!important/, '')

    css.split(/;/m).each do |rule|
      property, value = rule.split(/:/)

      next unless property && value

      property.strip!
      value.strip!

      if @property_set.include?(property)
        @collected_properties.add(property.to_sym)
        @values[property] << value
      end
    end
  end

  def collect_stylesheet(stylesheet)
    string = if stylesheet.is_a?(String)
               if stylesheet =~ %r{^http://}
                 open(stylesheet).read
               else
                 stylesheet
               end
             else
               stylesheet.read
             end

    # ignore CSS comments
    string.gsub!(%r{/\*.*?\*/}m, '')

    string.scan(/\{([^\}]+)\}/m) do |properties|
      collect_attribute(properties.first.strip)
    end
  end

  def collect_html(html)
    h, uri = if (html.is_a?(String) && html =~ %r{^http://})
               uri = URI::parse(html)
               response = Net::HTTP.get_response(uri)
               tries = 3
               while(tries > 0 && response.is_a?(Net::HTTPRedirection)) do
                 uri = URI::parse(response['location'])
                 response = Net::HTTP.get_response(uri)
                 tries -= 1
               end

               raise 'too many redirects' if response.is_a?(Net::HTTPRedirection)

               [Hpricot(response.body), uri]
             else
               Hpricot(html)
             end

    (h/'//[@style]').each do |element|
      collect_attribute(element['style'])
    end

    (h/'//style').each do |element|
      collect_stylesheet(element.inner_html)
    end

    (h/'//link[@rel=stylesheet]').each do |element|
      url = case element['href']
            when %r{^http://}
              element['href']
            else
              uri.merge(element['href']).to_s
            end

      collect_stylesheet(url)
    end
  end

  def properties
    @collected_properties.to_a
  end

  def [](property)
    raise StandardError.new("Property #{property} not being collected") unless @property_set.include?(property.to_s)

    values = @values[property.to_s]
    values.uniq!
    values
  end
end
