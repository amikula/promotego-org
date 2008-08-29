require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContacttoController do
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'send_mail'" do
    it "should take the form params and send the email" do
      encoded_email = Loopy::EmailObfuscator.obfuscate_email("email@domain.com")
      Obfuscated.should_receive(:deliver_contact).
        with("email@domain.com", "from_address",
             "[PromoteGo] A message from a PromoteGo.org user", "message",
             "club url")

      get 'send_mail', :email => encoded_email, :from => "from_address",
        :message => "message", :url => "club url"
    end

    it "should set a flash info message" do
      Obfuscated.should_receive(:deliver_contact)

      get 'send_mail', :email => ""

      flash[:notice].should_not be_nil
    end

    it "should redirect to home" do
      Obfuscated.should_receive(:deliver_contact)

      get 'send_mail', :email => ""

      response.should redirect_to('/')
    end
  end
end
