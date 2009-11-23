class ContacttoController < ApplicationController
  def new
    @from = current_user.email if logged_in?
  end

  def send_mail
    @email = params[:email]
    to = Loopy::EmailObfuscator.decode_email(@email)
    @from = params[:from]
    @message = params[:message]
    @subject = "[PromoteGo] A message from a PromoteGo.org user"
    @listing_url = params[:listing_url]

    if verify_recaptcha
      UserMailer.deliver_contact(to, @from, @subject, @message, @listing_url)

      flash[:notice] = t 'message_sent'

      redirect_to('/')
    else
      flash[:error] = t 'captcha_failed'
      render :action => "new"
    end
  end
end
