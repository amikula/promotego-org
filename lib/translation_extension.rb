module TranslationExtension
  def merge_translation_hashes(key, scope, locale=I18n.locale)
    # Start with the translation for tha last fallback, and merge all the other translation fallbacks
    # on top of it.
    I18n.fallbacks[locale].reverse.inject({}) do |hsh,l|
      translation_hash = I18n.t key, :scope => scope, :locale => l
      hsh.merge(translation_hash) if translation_hash
    end
  end

  # Return true unless province translation exists and contains special province 'none' with
  # value 'true'
  def has_provinces?(country)
    translation_hash = merge_translation_hashes(country, :provinces)

    !(translation_hash && translation_hash[:none] == 'true')
  end
end
