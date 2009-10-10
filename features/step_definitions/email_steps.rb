When /^I receive an email to "([^\"]*)"$/ do |email_address|
  @email = ActionMailer::Base.deliveries.find do |e|
    e.to.find{|a| a =~ /(?:^|<)test@example.com(?:$|>)/}
  end

  if @email
    ActionMailer::Base.deliveries.delete(@email)
  end

  @email.should_not be_nil
end

When "I click on the first link in the email" do
  link = @email.body.match(%r{http://[^\s]*})[0]
  link.should_not be_nil

  visit link
end

Then /^the email should contain "([^\"]+)"$/ do |text|
  @email.body.should include(text)
end
