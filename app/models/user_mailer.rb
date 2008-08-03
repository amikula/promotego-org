class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    url_options = {:activation_code => user.activation_code, :host => PUBLIC_HOSTNAME}
    url_options[:port] = PUBLIC_PORT if defined? PUBLIC_PORT
    @body[:url]  = activate_url(url_options)
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://promotego.org/"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = ADMIN_EMAIL
      @subject     = "[PROMOTEGO] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
