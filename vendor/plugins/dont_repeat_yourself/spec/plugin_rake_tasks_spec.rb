require File.dirname(__FILE__) + '/spec_helper'
require 'rake'

require 'dont_repeat_yourself'

describe "Rake file:" do    
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load File.dirname(__FILE__) + '/../tasks/dont_repeat_yourself_tasks.rake'
  end        
    
  DontRepeatYourself::REPORT_TYPES.each{|report_type|            
    it { @rake.should have_task("dry:report:#{report_type.downcase}", eval("DontRepeatYourself::Reporter::#{report_type.upcase}_REPORT_DESC")) }
  }    
      
  def have_task(task, described_by)
    return simple_matcher("have task '#{task}' #{described_by}")  do |rake| 
      rake[task].invoke        
    end        
  end
      
  after(:each) do
    Rake.application = nil
  end        

end

