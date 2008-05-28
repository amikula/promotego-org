# Include hook code here
if RAILS_ENV == 'test'
  require File.join(File.dirname(__FILE__), 'lib/dont_repeat_yourself/unit_testing_helpers')
end
