class UsersController < ApplicationController
  # render new.rhtml
  def new
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
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save

    if @user.errors.empty?
      UserMailer.deliver_signup_notification(@user)

      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      UserMailer.deliver_activation(current_user)
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
end
