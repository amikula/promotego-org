require File.dirname(__FILE__) + '/spec_helper'
require 'test/unit'

describe "Test::Unit extension" do
    
# TODO How to intercept failure???  
#  it "should have assert_DRY" do
#    assert_DRY(rails_application.with_netbeans_reporting) 
#  end

  it "should have a custom expectation matcher be_DRY" do    
    assert_DRY(ruby_code_in_rails_plugin("dont_repeat_yourself"))
  end  
    
  it "should use a fluent interface with a RSpec matcher which returns itself so we can specify: with_threshold_of_duplicate_lines" do    
    assert_DRY(
      ruby_code_in_rails_plugin("dont_repeat_yourself").
        with_threshold_of_duplicate_lines(2))
  end
  
  it "should use a fluent interface so we can specify: with_netbeans_reporting" do    
    assert_DRY(
      ruby_code_in_rails_plugin("dont_repeat_yourself").
        with_threshold_of_duplicate_lines(2).
        with_netbeans_reporting)
  end  
      
end