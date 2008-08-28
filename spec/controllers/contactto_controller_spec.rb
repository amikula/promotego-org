require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContacttoController do
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'send_mail'" do
  end
end
