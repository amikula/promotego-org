require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  fixtures :users

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  

  
  it 'signs up user with activation code' do
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  it 'activates user' do
    User.authenticate('aaron', 'test').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/')
    flash[:notice].should_not be_nil
    User.authenticate('aaron', 'test').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should be_nil
  end

  describe "edit action" do
    def do_get
      get :edit
    end

    it "redirects nan-logged-in users to 'new' action" do
      do_get

      response.should redirect_to(:action => :new)
    end

    describe "with logged in user" do
      before(:each) do
        @user = mock_model(User)
        @controller.stub!(:current_user).and_return(@user)
        @user.stub!(:has_role?).and_return(false)
      end

      it "redirects non-super-users to 'new' action" do
        @user.should_receive(:has_role?).with(:super_user).and_return(false)

        do_get

        response.should redirect_to(:action => :new)
      end

      it "renders edit form for super-users" do
        @user.should_receive(:has_role?).with(:super_user).and_return(true)

        do_get

        response.should render_template("edit")
      end

      it "redirects non-owners to 'new' action" do
        @user.should_receive(:has_role?).with(:owner).and_return(false)

        do_get

        response.should redirect_to(:action => :new)
      end

      it "renders edit form for owners" do
        @user.should_receive(:has_role?).with(:owner).and_return(true)

        do_get

        response.should render_template("edit")
      end
    end
  end

  describe "update action" do
    def do_post
      post :update
    end

    it "redirects non-logged-in users to 'new' action" do
      do_post

      response.should redirect_to(:action => :new)
    end

    describe "with logged in user" do
      before(:each) do
        @user = mock_model(User)
        @edit_user = mock_model(User)
        @controller.stub!(:current_user).and_return(@user)
        @user.stub!(:has_role?).and_return(false)
      end

      it "redirects non-owners and non-super-users to 'new' action" do
        do_post

        response.should redirect_to(:action => :new)
      end

      it "allows owners to update user metdata" do
        user_params = {"login" => "newlogin"}
        User.should_receive(:update).with(@edit_user.id.to_s, user_params)
        @user.should_receive(:has_role?).with(:owner).and_return(true)

        post :update, :id => @edit_user.id, :user => user_params
      end

      it "allows super-users to update user metdata" do
        user_params = {"login" => "newlogin"}
        User.should_receive(:update).with(@edit_user.id.to_s, user_params)
        @user.should_receive(:has_role?).with(:super_user).and_return(true)

        post :update, :id => @edit_user.id, :user => user_params
      end

      it "allows owners to set roles"

      it "allows super-users to set roles"
    end
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end
