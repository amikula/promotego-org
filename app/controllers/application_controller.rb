# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include TranslationExtension

  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :host_locale, :seo_encode, :seo_decode
  helper_method :has_provinces?, :merge_translation_hashes, :distance_units, :base_hostname
  helper_method :browser_language

  before_filter :set_locale
  before_filter :locale_redirect

  def locale_redirect
    browser_locale = request.preferred_language_from(I18n.available_locales).to_s
    subdomain_locale = extract_locale_from_subdomain

    if user_is_bot?
      if !subdomain_locale && browser_locale.present?
        # Turn into a string and take the first two letters, ie, 'en' of 'en-US'
        locale = browser_locale[0..1]

        redirect_to "http://#{locale}.#{base_hostname}#{request.request_uri}", :status => :moved_permanently
      end
    elsif subdomain_locale && browser_locale.starts_with?(subdomain_locale)
      redirect_to "http://#{base_hostname}#{request.request_uri}", :status => :moved_permanently
    end
  end

  def set_locale
    I18n.locale = if params[:locale]
                    params[:locale]
                  elsif(locale=extract_locale_from_subdomain)
                    locale
                  else
                    browser_language
                  end
  end

  def subdomain_locale?
    !!extract_locale_from_subdomain
  end

  # Return the default locale of the host.  If no locale is in the subdomain, return the
  # default locale.  Otherwise, return the locale in the hostname.
  def host_locale
    (extract_locale_from_subdomain || I18n.default_locale).to_sym
  end

  # Return the hostname with any locale information stripped off.
  def base_hostname
    locale, base_host = request.host.split('.', 2)

    if I18n.available_locales.map(&:to_s).include?(locale)
      base_host
    else
      request.host
    end
  end

  def seo_encode(string)
    string.tr(' ', '-') if string
  end

  def seo_decode(string)
    string.tr('-', ' ') if string
  end

  # Returns :mi or :km.  Eventually this will be a preference the user can set, but
  # we're starting with a default setting for the current locale.
  def distance_units
    I18n.t(:distance, :scope => :locale_units).to_sym
  end

  def browser_language
    request.preferred_language_from(I18n.available_locales)
  end

  def user_is_bot?
    request.headers['User-Agent'] =~ %r{msnbot|Baiduspider|Yahoo! Slurp|Speedy Spider|Yeti|Sosospider|Twiceler|Sogou|Yandex|Exabot|kosmix|Googlebot|al_viewer|MLBot|aiHitBot|Linguee Bot|Cabot/Nutch|80legs|YoudaoBot|Snapbot|SurveyBot}
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
