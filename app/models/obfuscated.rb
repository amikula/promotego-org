class Obfuscated < ActionMailer::Base
  def contact(to, from, subject, message)
    subject    subject
    recipients to
    from       from
    body       :message => message
  end
end
