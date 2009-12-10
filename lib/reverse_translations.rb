class ReverseTranslations
  class << self
    def do_reverse(name)
      print "Writing reverse #{name}..."
      I18n.available_locales.each do |locale|
        hash = I18n.t(name, :locale => locale)

        # Only continue if the locale of the translation matches our locale, ie, if there was no fallback translation
        if has_locale(hash, locale)
          new_data = {locale => {"reverse_#{name}".to_sym => ReverseTranslations.go(hash)}}
          print "#{locale}..."

          # Make sure the directory exists
          FileUtils.mkdir_p(File.join(Rails.root, 'lib', 'locale', locale.to_s))

          # Write the reverse data to the file
          File.open(File.join(Rails.root, 'lib', 'locale', locale.to_s, "reverse_#{name}.rb"), 'w') do |file|
            file << new_data.inspect
            file << "\n"
          end
        end
      end

      print "\n"
    end

    def has_locale(hash, locale)
      hash.each_pair do |k,v|
        if v.respond_to?(:locale)
          return true if v.locale == locale
        elsif v.is_a?(Hash) && has_locale(v, locale)
          return true
        end
      end

      return false
    end

    def go(hash)
      returning({}) do |rethash|
        hash.each_pair do |k,v|
          case v
          when Hash
            rethash[k] = go(v)
          else
            rethash[v.to_sym] = k.to_s
          end
        end
      end
    end
  end
end
