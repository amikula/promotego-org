require File.dirname(__FILE__) + '/../spec_helper'

# Idea for this test shamelessly stolen from:
# http://madhatted.com/2008/7/10/rspec-real-world-testing
shared_examples_for "promotego.org email" do
  it "should have a prefix on the subject" do
    @email.subject.should =~ /^\[PROMOTEGO\] /
  end

  it "should be from admin" do
    @email.from.should == [ADMIN_EMAIL]
  end

  it "should have the current time" do
    @email.date.to_i.should == @now.to_i
  end

  it "should be sent to the user's email address" do
    @email.to.should == [@user.email]
  end
end

describe UserMailer do
  before(:each) do
    @now = Time.now
    Time.should_receive(:now).any_number_of_times.and_return(@now)
    @user = mock_model(User, :email => "user_email",
                             :login => "user_login",
                             :password => "user_password",
                             :activation_code => "ABC123")
  end

  describe "when sending a signup notification e-mail" do
    before(:each) do
      @email = UserMailer.create_signup_notification(@user)
    end

    it_should_behave_like "promotego.org email"

    it "should contain the activation_code" do
      puts
      @email.body.should =~ /#{@user.activation_code}/
    end

    it "should contain the correct subject" do
      @email.subject.should =~ %r{Please activate}
    end
  end

  describe "when sending an activation e-mail" do
    before(:each) do
      @email = UserMailer.create_activation(@user)
    end

    it_should_behave_like "promotego.org email"

    it "should contain the site url" do
      @email.body.should =~ %r{http://testhost/}
    end

    it "should contain the correct subject" do
      @email.subject.should =~ %r{activated}
    end
  end

  describe "when sending a contact e-mail" do
    before(:each) do
      @email = UserMailer.create_contact('to_address', 'from_address',
                                         'subject', 'message_body',
                                         'http://some.url')
    end

    it "should have the correct sender" do
      @email.from.should == ['contact@promotego.org']
    end

    it "should be sent to the correct recipient" do
      @email.to.should == ['to_address']
    end

    it "should contain the correct url" do
      @email.body.should =~ %r{http://some.url}
    end

    it "should contain the correct subject" do
      @email.subject.should == 'subject'
    end

    it "should contain the message body" do
      @email.body.should =~ %r{message_body}
    end

    it "should have the from address in the message body" do
      puts @email.body

      @email.body.should =~ %r{from_address}
    end
  end
end
