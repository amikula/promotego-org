require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ForgotPasswordController do
  describe "POST 'create'" do
    it "redirects to show with a flash message if the user does not exist" do
      User.should_receive(:find_by_login).with('test_login').and_return(nil)

      post 'create', :login => 'test_login'

      response.should redirect_to(forgot_password_path)
      flash[:warning].should =~ /does not exist/i
    end

    it "redirects to show with a flash message if the user is not provided" do
      User.should_receive(:find_by_login).with('').and_return(nil)

      post 'create', :login => ''

      response.should redirect_to(forgot_password_path)
      flash[:warning].should =~ /please provide a username to continue/i
    end

    it "sends a password reset email to the user represented by the login" do
      user = mock(User)
      user.should_receive(:reset_perishable_token!)

      User.should_receive(:find_by_login).with('test_user').and_return(user)
      UserMailer.should_receive(:deliver_forgot_password).with(user)

      post 'create', :login => 'test_user'
    end
  end

  describe "GET 'show'" do
    it "is successful" do
      get 'show'
      response.should be_success
    end
  end
end
