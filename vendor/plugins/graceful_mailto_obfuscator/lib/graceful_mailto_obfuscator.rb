module Loopy
  module EmailObfuscator
    def self.included(base)
      base.alias_method_chain :mail_to, :graceful_obfuscation
    end
    
    def self.obfuscate_email(email)
      email = email.tr "a-zA-Z", "n-za-mN-ZA-M"
      email = email.gsub /@/, "%5E"
      email.gsub /\./, "%24"
    end
    
    def self.decode_email(email)
      email = email.gsub /%5E/, '@'
      email = email.gsub /%24/, '.'
      email.tr "a-zA-Z", "n-za-mN-ZA-M"
    end
    
    def mail_to_with_graceful_obfuscation(*args)
      mailto = mail_to_without_graceful_obfuscation(*args)
      match, email = *mailto.match(/mailto:(.*)"/)
      mailto.gsub! "mailto:", "/contactto\/new/"
      mailto.gsub! /^<a /, "<a class=\"obfuscated\" "
      mailto.gsub! email, Loopy::EmailObfuscator.obfuscate_email(email)
    end
  end
end

ActionView::Helpers::UrlHelper.send :include, Loopy::EmailObfuscator
