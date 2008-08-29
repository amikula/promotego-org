class ContacttoController < ApplicationController
  def new
    @from = current_user.email if logged_in?
  end

  def send_mail
    to = Loopy::EmailObfuscator.decode_email(params[:email])
    from = params[:from]
    message = params[:message]
    subject = "[PromoteGo] A message from a PromoteGo.org user"
    url = params[:url]

    Obfuscated.deliver_contact(to, from, subject, message, url)

    flash[:notice] = "Your message has been sent"

    redirect_to('/')
  end
end
