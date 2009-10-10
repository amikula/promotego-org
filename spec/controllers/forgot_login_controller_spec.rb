require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ForgotLoginController do
  describe "POST 'create'" do
    it "redirects to show with a flash message if the user does not exist" do
      User.should_receive(:find_by_email).with('test_email').and_return(nil)

      post 'create', :email => 'test_email'

      response.should redirect_to(forgot_login_path)
      flash[:warning].should =~ /not in the system/i
    end

    it "redirects to show with a flash message if the user is not provided" do
      User.should_receive(:find_by_email).with('').and_return(nil)

      post 'create', :email => ''

      response.should redirect_to(forgot_login_path)
      flash[:warning].should =~ /please provide your email address to continue/i
    end

    it "sends a login reminder email to the user represented by the email address" do
      user = mock(User)
      user.should_receive(:reset_perishable_token!)

      User.should_receive(:find_by_email).with('test_email').and_return(user)
      UserMailer.should_receive(:deliver_forgot_login).with(user)

      post 'create', :email => 'test_email'
    end
  end

  describe "GET 'show'" do
    it "is successful" do
      get 'show'
      response.should be_success
    end
  end
end
