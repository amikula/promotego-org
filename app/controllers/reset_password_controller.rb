class ResetPasswordController < ApplicationController
  before_filter :require_no_user

  def show
    @user = User.find_using_perishable_token(params[:id])

    unless @user
      redirect_to root_path
      flash[:warning] = t 'password_reset_invalid'
    end
  end

  def update
    @user = User.find_using_perishable_token(params[:id])

    if @user
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]

      unless @user.save
        render :show
      end
    else
      redirect_to root_path
      flash[:warning] = t 'password_reset_invalid'
    end
  end
end
