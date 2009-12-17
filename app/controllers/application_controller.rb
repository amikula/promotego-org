# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :host_locale, :seo_encode, :seo_decode
  helper_method :has_provinces?, :merge_translation_hashes
  before_filter :set_locale

  def set_locale
    I18n.locale = if params[:locale]
                    params[:locale]
                  elsif(locale=extract_locale_from_subdomain)
                    locale
                  else
                    request.preferred_language_from(I18n.available_locales)
                  end
  end

  def subdomain_locale?
    !!extract_locale_from_subdomain
  end

  def host_locale
    (extract_locale_from_subdomain || I18n.default_locale).to_sym
  end

  def seo_encode(string)
    string.tr(' ', '-') if string
  end

  def seo_decode(string)
    string.tr('-', ' ') if string
  end

  def merge_translation_hashes(key, scope, locale=I18n.locale)
    # Start with the translation for tha last fallback, and merge all the other translation fallbacks
    # on top of it.
    I18n.fallbacks[locale].reverse.inject({}) do |hsh,l|
      translation_hash = t key, :scope => scope, :locale => l
      hsh.merge(translation_hash) if translation_hash
    end
  end

  # Return true unless province translation exists and contains special province 'none' with
  # value 'true'
  def has_provinces?(country)
    translation_hash = merge_translation_hashes(country, :provinces)

    !(translation_hash && translation_hash[:none] == 'true')
  end

private
  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    (parsed_locale && I18n.available_locales.include?(parsed_locale.to_sym)) ? parsed_locale : nil
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def current_user=(_current_user)
    @current_user = _current_user
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = t 'must_log_in'
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = t 'must_log_out'
      redirect_to account_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
