class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create, :activate]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def show
    @user = @current_user
  end

  def edit
    unless(current_user && (current_user.has_role?(:super_user) ||
                            current_user.has_role?(:owner)))
      redirect_to :action => :new
    else
      @roles = Role.find(:all)
      unless(current_user.has_role?(:owner))
        @roles.delete_if{|role| role.name == "owner"}
      end
    end
  end

  def update
    if(current_user && (current_user.has_role?(:owner) ||
                        current_user.has_role?(:super_user)))
      roles = params[:user].delete("roles")
      User.update(params[:id], params[:user])
      if(roles)
        role_ids = roles.collect{|role| role.to_d}
        User.find(params[:id]).set_roles(role_ids, current_user)
      end
    else
      redirect_to :action => :new
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.deliver_signup_notification(@user)
      flash[:notice] = "Account registered!  Check your email for your activation link."
      redirect_to :controller => :home, :action => :show, :page => :validate
    else
      render :action => :new
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false :
      User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      UserMailer.deliver_activation(current_user)
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
end
