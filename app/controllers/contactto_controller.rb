class ContacttoController < ApplicationController
  def new
  end

  def send_mail
    #decoded_email = Loopy::EmailObfuscator.decode_email(CGI.escape(params[:email]))
  end
end
