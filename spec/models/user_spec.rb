require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :users

  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload
      @user.activation_code.should_not be_nil
    end
  end

  it 'requires login' do
    lambda do
      u = create_user(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:login => 'quentin2')
    User.authenticate('quentin2', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin', 'test').should == users(:quentin)
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  describe "has many" do
    before(:each) do
      @user = User.new
    end

    it "locations" do
      @user.locations << Location.new
      @user.locations << Location.new
    end

    it "user_roles" do
      @user.user_roles << UserRole.new
      @user.user_roles << UserRole.new
    end

    it "roles" do
      @user.stub!(:id).and_return(1)
      @user.stub!(:new_record?).and_return(false)
      @user.roles << mock_model(Role)
      @user.roles << mock_model(Role)
    end
  end

  describe "has_role?" do
    before(:each) do
      @user = User.new
    end

    it "should query roles by name, using the given symbol" do
      @user.roles.should_receive(:find_by_name).with("administrator").
        and_return(:administrator_role)
      @user.has_role?(:administrator).should_not be_false
    end
  end

  describe "add_role" do
    before(:each) do
      @user = User.new
      @granting_user = mock_model(User)

      @roles = {:owner => mock_model(Role, :name => "owner"),
                  :administrator => mock_model(Role, :name => "administrator"),
                  :super_user => mock_model(Role, :name => "super_user")}
    end

    describe "with role name" do
      it "should allow owners to create other owners" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(true)
        user_should_add_role(:owner)

        @user.add_role(:owner, @granting_user)
      end

      it "should raise an error when non-owners try to create owners" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(false)
        Role.should_receive(:find_by_name).with("owner").and_return(mock_model(Role, :name => "owner"))

        lambda {@user.add_role(:owner, @granting_user)}.
          should raise_error(SecurityError)
      end

      it "should allow owners to create super-users" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(true)
        user_should_add_role(:super_user)

        @user.add_role(:super_user, @granting_user)
      end

      it "should raise an error when non-owners try to create super-users" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(false)
        Role.should_receive(:find_by_name).with("super_user").and_return(mock_model(Role, :name => "super_user"))

        lambda {@user.add_role(:super_user, @granting_user)}.
          should raise_error(SecurityError)
      end

      it "should allow super-users to create administrators" do
        @granting_user.should_receive(:has_role?).with(:super_user).
          and_return(true)
        user_should_add_role(:administrator)

        @user.add_role(:administrator, @granting_user)
      end

      it "should raise an error when non-super-users try to create other administrators" do
        @granting_user.should_receive(:has_role?).with(:super_user).
          and_return(false)
        Role.should_receive(:find_by_name).with("administrator").and_return(mock_model(Role, :name => "administrator"))

        lambda {@user.add_role(:administrator, @granting_user)}.
          should raise_error(SecurityError)
      end
    end

    describe "with role id" do
      it "should take an argument of role id number and granting user" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(true)
        role = mock_and_find_role_by_id("owner")
        @user.add_role(role.id, @granting_user)
      end

      def mock_and_find_role_by_id(role_name)
        role = mock_model(Role, :name => role_name)
        Role.should_receive(:find).with(role.id).and_return(role)
        return role
      end
    end

    def user_should_add_role(role_sym)
      user_role = mock_model(UserRole)
      UserRole.should_receive(:new).and_return(user_role)
      user_role.should_receive(:granting_user=).with(@granting_user)

      role = mock_model(Role, :name => role_sym.to_s)
      Role.should_receive(:find_by_name).with(role_sym.to_s).
        and_return(role)
      user_role.should_receive(:role=).with(role)

      @user.user_roles.should_receive(:<<).with(user_role)
    end
  end

  describe "remove_role" do
    before(:each) do
      @user = User.new
      @granting_user = mock_model(User)

      @roles = {:owner => mock_model(Role, :name => "owner"),
                :administrator => mock_model(Role, :name => "administrator"),
                :super_user => mock_model(Role, :name => "super_user")}
    end

    describe "with role symbol" do
      it "should allow owners to revoke other owners" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(true)
        user_should_remove_role(:owner)

        @user.remove_role(:owner, @granting_user)
      end

      it "should raise an error when non-owners try to revoke owners" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(false)
        mock_and_find_role_by_name("owner")

        lambda {@user.remove_role(:owner, @granting_user)}.
          should raise_error(SecurityError)
      end

      it "should allow owners to revoke super-users" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(true)
        user_should_remove_role(:super_user)

        @user.remove_role(:super_user, @granting_user)
      end

      it "should raise an error when non-owners try to revoke super-users" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(false)
        mock_and_find_role_by_name("super_user")

        lambda {@user.remove_role(:super_user, @granting_user)}.
          should raise_error(SecurityError)
      end

      it "should allow super-users to revoke administrators" do
        @granting_user.should_receive(:has_role?).with(:super_user).
          and_return(true)
        user_should_remove_role(:administrator)

        @user.remove_role(:administrator, @granting_user)
      end

      it "should raise an error when non-super-users try to revoke administrators" do
        @granting_user.should_receive(:has_role?).with(:super_user).
          and_return(false)
        mock_and_find_role_by_name("administrator")

        lambda {@user.remove_role(:administrator, @granting_user)}.
          should raise_error(SecurityError)
      end

      def user_should_remove_role(role_sym)
        user_roles = Object.new
        role = mock_model(Role, :name => role_sym.to_s)
        Role.should_receive(:find_by_name).with(role_sym.to_s).and_return(role)
        user_role = mock_model(UserRole)
        user_roles.should_receive(:find_by_role).with(role).and_return(user_role)
        @user.should_receive(:user_roles).and_return(user_roles)
        user_role.should_receive(:destroy)
      end

      def mock_and_find_role_by_name(role_name)
        role = mock_model(Role, :name => role_name)
        Role.should_receive(:find_by_name).with(role_name).and_return(role)
        return role
      end
    end

    describe "with role id" do
      it "should allow owners to revoke other owners" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(true)
        user_should_remove_role(:owner)

        @user.remove_role(@roles[:owner].id, @granting_user)
      end

      it "should raise an error when non-owners try to revoke owners" do
        @granting_user.should_receive(:has_role?).with(:owner).and_return(false)
        role = mock_and_find_role_by_id("owner")

        lambda {@user.remove_role(role.id, @granting_user)}.
          should raise_error(SecurityError)
      end

      def user_should_remove_role(role_sym)
        user_roles = Object.new
        role = @roles[role_sym]
        Role.should_receive(:find).with(role.id).and_return(role)
        user_role = mock_model(UserRole)
        user_roles.should_receive(:find_by_role).with(role).and_return(user_role)
        @user.should_receive(:user_roles).and_return(user_roles)
        user_role.should_receive(:destroy)
      end

      def mock_and_find_role_by_id(role_name)
        role = mock_model(Role, :name => role_name)
        Role.should_receive(:find).with(role.id).and_return(role)
        return role
      end
    end
  end

  describe "set_roles" do
    before(:each) do
      @user = User.new
      @granting_user = mock_model(User)

      @roles = {:owner => mock_model(Role, :name => "owner"),
                :administrator => mock_model(Role, :name => "administrator"),
                :super_user => mock_model(Role, :name => "super_user")}
    end

    it "should remove roles previously on the user's list of roles" do
      @user.should_receive(:roles).and_return([@roles[:administrator],
        @roles[:super_user]])
      @user.should_receive(:remove_role).
        with(@roles[:super_user].id, @granting_user)

      @user.set_roles([@roles[:administrator].id], @granting_user)
    end

    it "should add roles previously not on the user's list of roles" do
      @user.should_receive(:roles).and_return([@roles[:administrator]])
      @user.should_receive(:add_role).
        with(@roles[:super_user].id, @granting_user)

      @user.set_roles([@roles[:administrator].id, @roles[:super_user].id],
                      @granting_user)
    end

    it "should both add and remove roles" do
      @user.should_receive(:roles).and_return([@roles[:administrator]])
      @user.should_receive(:add_role).
        with(@roles[:super_user].id, @granting_user)
      @user.should_receive(:remove_role).
        with(@roles[:administrator].id, @granting_user)

      @user.set_roles([@roles[:super_user].id], @granting_user)
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end

