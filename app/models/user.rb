require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.act_like_restful_authentication = true
  end

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  has_many :locations

  has_many :user_roles
  has_many :roles, :through => :user_roles

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 6..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_format_of       :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  before_create :make_activation_code
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def deactivate
    @activated = false
    self.activated_at = nil
    self.activation_code = 'X'
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def add_role(role_spec, granting_user)
    case role_spec
    when Symbol:
      role = Role.find_by_name(role_spec.to_s)
    when Fixnum:
      role = Role.find(role_spec)
    else
      raise ArgumentError.new("Don't know how to handle class #{role_spec.class}")
    end

    if granting_user.has_role?(role.parent) || granting_user.has_role?(:owner)
      add_role_internal(role, granting_user)
    else
      raise SecurityError.new("User has insufficient permissions to assign role #{role.name}")
    end
  end

  def remove_role(role_spec, granting_user)
    case role_spec
    when Symbol:
      role = Role.find_by_name(role_spec.to_s)
    when Fixnum:
      role = Role.find(role_spec)
    else
      raise ArgumentError.new("Don't know how to handle class #{role_spec.class}")
    end

    case role.name
    when "owner"
      if granting_user.has_role?(:owner)
        remove_role_internal(role)
      else
        raise SecurityError.new("Only owners may remove owner role")
      end
    when "super_user"
      if granting_user.has_role?(:owner)
        remove_role_internal(role)
      else
        raise SecurityError.new("Only owners may remove super_user role")
      end
    when "administrator"
      if granting_user.has_role?(:super_user)
        remove_role_internal(role)
      else
        raise SecurityError.new("Only super_users may remove administrator role")
      end
    end
  end

  def has_role?(role_spec)
    case role_spec
    when nil
      return false
    when Role
      role = role_spec
      return true if roles.include?(role)
    else
      return true if roles.find_by_name(role_spec.to_s)
      role = Role.find_by_name(role_spec.to_s)
    end

    roles.each do |current_role|
      return true if role.ancestors.include?(current_role)
    end

    false
  end

  def set_roles(role_ids, granting_user)
    my_role_ids = roles.collect{|role| role.id}

    my_role_ids.each do |id|
      unless(role_ids.include?(id))
        remove_role(id, granting_user)
      end
    end

    role_ids.each do |id|
      unless(my_role_ids.include?(id))
        add_role(id, granting_user)
      end
    end
  end

  def administers(object)
    case object
    when Location
      has_role?(:administrator)
    when Affiliation
      administers(object.affiliate)
    when Affiliate
      has_role?("#{object.name.downcase}_administrator")
    end
  end

  private
    def add_role_internal(role, granting_user)
      user_role = UserRole.new
      user_role.granting_user = granting_user

      user_role.role = role

      user_roles << user_role
    end

    def remove_role_internal(role)
      user_role = user_roles.find_by_role(role)
      user_role.destroy if user_role
    end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_activation_code

      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
end
