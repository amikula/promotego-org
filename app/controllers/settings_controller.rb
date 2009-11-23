class SettingsController < ApplicationController
  before_filter :require_user

  def edit
    @user = current_user
  end

  def update
    @user                       = current_user
    @user.password              = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    if @user.save
      flash[:notice] = t 'password_changed'
      redirect_to edit_settings_path
    else
      render :action => 'edit'
    end
  end
end
