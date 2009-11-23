class ForgotPasswordController < ApplicationController
  before_filter :require_no_user

  def create
    user = User.find_by_login(params[:login])

    if user
      user.reset_perishable_token!
      UserMailer.deliver_forgot_password(user)
    else
      if params[:login].blank?
        flash[:warning] = t 'provide_username'
      else
        flash[:warning] = t 'username_unknown'
      end

      redirect_to :action => :show
    end
  end
end
