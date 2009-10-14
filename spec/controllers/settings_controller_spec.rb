require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SettingsController do
  before :each do
    @user = mock(User)
    controller.stub!(:current_user).and_return(@user)
  end

  describe "GET 'edit'" do
    it 'sets @user to the current user' do
      get 'edit'

      assigns[:user].should == @user
    end
  end

  describe "PUT 'update'" do
    it "sets the user's password" do
      @user.should_receive(:password=).with('abcdef')
      @user.should_receive(:password_confirmation=).with('abcdef')
      @user.should_receive(:save).and_return(true)

      put 'update', :password => 'abcdef', :password_confirmation => 'abcdef'

      response.should redirect_to(edit_settings_path)
    end

    it "does not set the user's password if the passwond does not match" do
      @user.stub!(:password=)
      @user.stub!(:password_confirmation=)
      @user.should_receive(:save).and_return(false)

      put 'update', :password => 'abcdef', :password_confirmation => 'abcdef'

      response.should render_template(:edit)
    end
  end
end
