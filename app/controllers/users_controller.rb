class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  # TODO resolve update and create actions
  #def update
  #  if(current_user && (current_user.has_role?(:owner) ||
  #                      current_user.has_role?(:super_user)))
  #    roles = params[:user].delete("roles")
  #    User.update(params[:id], params[:user])
  #    if(roles)
  #      role_ids = roles.collect{|role| role.to_d}
  #      User.find(params[:id]).set_roles(role_ids, current_user)
  #    end
  #  else
  #    redirect_to :action => :new
  #  end
  #end

  #def create
  #  cookies.delete :auth_token
  #  # protects against session fixation attacks, wreaks havoc with
  #  # request forgery protection.
  #  # uncomment at your own risk
  #  # reset_session
  #  @user = User.new(params[:user])
  #  @user.save

  #  if @user.errors.empty?
  #    UserMailer.deliver_signup_notification(@user)

  #    self.current_user = @user
  #    flash[:notice] = "Thanks for signing up!"
  #    redirect_to :controller => :home, :action => :show, :page => :validate
  #  else
  #    render :action => 'new'
  #  end
  #end
end
