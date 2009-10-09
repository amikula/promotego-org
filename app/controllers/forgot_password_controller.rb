class ForgotPasswordController < ApplicationController
  before_filter :require_no_user

  def create
    user = User.find_by_login(params[:login])

    if user
      user.reset_perishable_token!
      UserMailer.deliver_forgot_password(user)
    else
      if params[:login].blank?
        flash[:warning] = "Please provide a login name to continue"
      else
        flash[:warning] = "The user you specified does not exist"
      end

      redirect_to :action => :show
    end
  end
end
