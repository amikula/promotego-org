module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /the homepage/
      '/'
    when /the new account page/
      new_account_path
    when /the validation message page/
      home_path :page => :validate
    when /the forgot password page/
      forgot_password_path
    when /the reset password page/
      reset_password_path
    when /the login page/
      new_user_session_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
