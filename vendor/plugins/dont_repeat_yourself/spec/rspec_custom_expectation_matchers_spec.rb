require File.dirname(__FILE__) + '/spec_helper'

describe "RSpec Custom Matchers" do
  
  # We have some duplicate lines in app/model: WILL FAIL
#  it { rails_application.with_netbeans_reporting.should be_DRY }
  
  it "should have a custom expectation matcher be_DRY for the current rails_application" do    
    rails_application.should_not be_DRY # our application is not DRY on purpose ;-)
  end 
  
  it "should have a custom expectation matcher be_DRY" do    
    ruby_code_in_rails_plugin("dont_repeat_yourself").
      should be_DRY
  end  
  
  it { ruby_code_in_rails_plugin("dont_repeat_yourself").
         should be_DRY }   
  
  it "should use a fluent interface with a RSpec matcher which returns itself so we can specify: with_threshold_of_duplicate_lines" do    
    ruby_code_in_rails_plugin("dont_repeat_yourself").
      with_threshold_of_duplicate_lines(2).
        should be_DRY
  end
  
  it "should use a fluent interface so we can specify: with_netbeans_reporting" do    
    ruby_code_in_rails_plugin("dont_repeat_yourself").
      with_threshold_of_duplicate_lines(2).
      with_netbeans_reporting.
        should be_DRY
  end  
    
end