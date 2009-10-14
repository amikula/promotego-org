class SettingsController < ApplicationController
  before_filter :require_user

  def edit
    @user = current_user
  end

  def update
    @user                       = current_user
    @user.password              = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    @user.save

    flash[:notice] = "Your password has been changed"

    redirect_to edit_settings_path
  end
end
