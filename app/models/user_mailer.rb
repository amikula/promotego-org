class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user, 'Please activate your new account')
  
    url_options = {:activation_code => user.activation_code}
    @body[:url]  = activate_url(url_options)
  end
  
  def activation(user)
    setup_email(user, 'Your account has been activated!')
    @body[:url]  = root_url
  end
  
  def contact(to, sender, subject, message, url)
    subject    subject
    recipients to
    from       ADMIN_EMAIL
    body       :message => message, :url => url, :sender => sender
  end

  protected
    def setup_email(user, subject)
      recipients  "#{user.email}"
      from        ADMIN_EMAIL
      subject     "[PROMOTEGO] #{subject}"
      sent_on     Time.now
      body        :user => user
    end
end
