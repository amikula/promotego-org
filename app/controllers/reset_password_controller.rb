class ResetPasswordController < ApplicationController
  before_filter :require_no_user

  def show
    @user = User.find_using_perishable_token(params[:id])

    unless @user
      redirect_to root_path
      flash[:warning] = "Sorry, but your password reset token is either expired or invalid"
    end
  end

  def update
    @user = User.find_using_perishable_token(params[:id])

    if @user
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]

      @user.save!
    else
      redirect_to root_path
      flash[:warning] = "Sorry, but your password reset token is either expired or invalid"
    end
  end
end
