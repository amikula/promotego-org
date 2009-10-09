require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResetPasswordController do
  describe "GET 'show'" do
    it 'sets the user from the perishable token' do
      User.should_receive(:find_using_perishable_token).with('perishable').and_return(:user)

      get 'show', :id => 'perishable'

      assigns[:user].should == :user
    end

    it 'redirects to homepage with a flash message if the user is not found' do
      User.should_receive(:find_using_perishable_token).and_return(nil)

      get 'show', :id => 'expired_perishable'

      flash[:warning].should =~ /expired/
      flash[:warning].should =~ /invalid/
      response.should redirect_to(root_path)
    end
  end

  describe "put 'update'" do
    it 'redirects to homepage with a flash message if the user is not found' do
      User.should_receive(:find_using_perishable_token).and_return(nil)

      put 'update', :id => 'expired_perishable'

      flash[:warning].should =~ /expired/
      flash[:warning].should =~ /invalid/
      response.should redirect_to(root_path)
    end

    it 'sets password and password confirmation to the params in the request and saves the user' do
      user = mock(User)
      user.should_receive(:password=).with('password')
      user.should_receive(:password_confirmation=).with('password_confirmation')
      user.should_receive(:save!)
      User.should_receive(:find_using_perishable_token).with('perishable_token').
        and_return(user)

      put 'update', :id => 'perishable_token', :password => 'password',
                    :password_confirmation => 'password_confirmation'
    end
  end
end
