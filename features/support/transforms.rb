Transform /^user "(\w+)"$/ do |login|
  User.find_by_login login
end
