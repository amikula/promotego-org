class ContacttoController < ApplicationController
  def new
  end

  def send_mail
    to = Loopy::EmailObfuscator.decode_email(params[:email])
    from = params[:from]
    message = params[:message]
    subject = "[PromoteGo] A message from a PromoteGo.org user"

    Obfuscated.deliver_contact(to, from, subject, message)

    flash[:info] = "Your message has been sent"
  end
end
