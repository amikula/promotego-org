Given /^I have an account called "(\w+)"$/ do |login|
  User.create(:login => login, :password => "pass1234", :email => 'test@example.com').activate
end

Given /^there is no (user "[^\"]+")$/ do |login|
  user = User.find_by_login("login")
  user.destroy if user
end

Then /^(user "[^\"]+") should be active$/ do |user|
  user.should be_active
end

Then /^(user "[^\"]+") should not be active$/ do |user|
  user.should_not be_active
end

Then /^the user "([^\"]*)" should have password "([^\"]*)"$/ do |login, password|
  user = User.authenticate(login, password)

  user.should_not be_nil
  user.login.should == login
end
