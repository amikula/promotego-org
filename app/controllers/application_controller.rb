# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
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
