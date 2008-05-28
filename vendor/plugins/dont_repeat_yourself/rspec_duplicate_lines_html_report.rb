ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../config/environment")

require File.dirname(__FILE__) + '/lib/dont_repeat_yourself'

reporter = DontRepeatYourself::Reporter.new
reporter.simian_runner.add_directory_to_search_for_duplicate_lines("vendor/reporters/rspec")
reporter.html_report