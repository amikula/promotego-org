class ForgotLoginController < ApplicationController
  before_filter :require_no_user

  def create
    user = User.find_by_email(params[:email])

    if user
      user.reset_perishable_token!
      UserMailer.deliver_forgot_login(user)
    else
      if params[:email].blank?
        flash[:warning] = "Please provide your email address to continue"
      else
        flash[:warning] = "The email address you entered is not in the system"
      end

      redirect_to :action => :show
    end
  end
end
