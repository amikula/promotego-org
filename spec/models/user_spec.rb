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

  describe "has_role" do
    before(:each) do
      @user = User.new
    end

    it "should query roles by name, using the given symbol" do
      @user.roles.should_receive(:find_by_name).with("administrator").
        and_return(:administrator_role)
      @user.has_role(:administrator).should_not be_false
    end
  end

  describe "add_role" do
    before(:each) do
      @user = User.new
      @granting_user = mock_model(User)
    end

    it "should take an argument of role and granting user" do
      @user.add_role(:role, @granting_user)
    end

    it "should allow owners to create other owners" do
      @granting_user.should_receive(:has_role).with(:owner).and_return(true)
      user_should_add_role(:owner)

      @user.add_role(:owner, @granting_user)
    end

    it "should raise an error when non-owners try to create owners" do
      @granting_user.should_receive(:has_role).with(:owner).and_return(false)

      lambda {@user.add_role(:owner, @granting_user)}.
        should raise_error(SecurityError)
    end

    it "should allow owners to create super-users" do
      @granting_user.should_receive(:has_role).with(:owner).and_return(true)
      user_should_add_role(:super_user)

      @user.add_role(:super_user, @granting_user)
    end

    it "should raise an error when non-owners try to create super-users" do
      @granting_user.should_receive(:has_role).with(:owner).and_return(false)

      lambda {@user.add_role(:super_user, @granting_user)}.
        should raise_error(SecurityError)
    end

    it "should allow super-users to create administrators" do
      @granting_user.should_receive(:has_role).with(:super_user).
        and_return(true)
      user_should_add_role(:administrator)

      @user.add_role(:administrator, @granting_user)
    end

    it "should raise an error when non-super-users try to create other administrators" do
      @granting_user.should_receive(:has_role).with(:super_user).
        and_return(false)

      lambda {@user.add_role(:administrator, @granting_user)}.
        should raise_error(SecurityError)
    end

    def user_should_add_role(role_sym)
      user_role = mock_model(UserRole)
      UserRole.should_receive(:new).and_return(user_role)
      user_role.should_receive(:granting_user=).with(@granting_user)

      Role.should_receive(:find_by_name).with(role_sym.to_s).
        and_return(:role)
      user_role.should_receive(:role=).with(:role)

      @user.user_roles.should_receive(:<<).with(user_role)
    end
  end

protected
  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
