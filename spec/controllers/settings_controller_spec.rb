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
      @user.should_receive(:save)

      put 'update', :password => 'abcdef', :password_confirmation => 'abcdef'

      response.should redirect_to(edit_settings_path)
    end
  end
end
