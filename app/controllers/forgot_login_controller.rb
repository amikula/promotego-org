class ForgotLoginController < ApplicationController
  before_filter :require_no_user

  def create
    user = User.find_by_email(params[:email])

    if user
      user.reset_perishable_token!
      UserMailer.deliver_forgot_login(user)
    else
      if params[:email].blank?
        flash[:warning] = t 'provide_email'
      else
        flash[:warning] = t 'email_unknown'
      end

      redirect_to :action => :show
    end
  end
end
