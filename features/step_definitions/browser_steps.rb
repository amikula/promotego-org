Given /^my '([^\']*)' header is '([^\']*)'$/ do |name,value|
  header name, value
end

Given 'I am a search bot' do
  header 'User-Agent', 'Googlebot'
end

# Webrat doesn't set the host header, ever.  So if redirecting is based
# on host header, the host never changes on redirect and we get an infinite
# redirect loop.  Just suppress the error.
When /^I work around broken redirect behavior and go to (.+)$/ do |page_name|
  begin
    visit path_to(page_name)
  rescue Webrat::InfiniteRedirectError
  end
end

Then /^I should not have been redirected$/ do
  redirect?.should be_false
end

Then /^I should have been redirected$/ do
  redirect?.should be_true
end

Then /^my host should be '([^\']*)'$/ do |host|
  current_url.should =~ %r{^http://#{host}}
end
