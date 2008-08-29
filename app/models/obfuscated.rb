class Obfuscated < ActionMailer::Base
  def contact(to, from, subject, message, url)
    subject    subject
    recipients to
    from       "contact@promotego.org"
    body       :message => message, :url => url, :from => from
  end
end
