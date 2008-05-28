require File.dirname(__FILE__) + '/spec_helper'
require "dont_repeat_yourself/reporter"

describe DontRepeatYourself::Reporter do

  before :each do     
    @reporter = DontRepeatYourself::Reporter.new
  end 
             
  describe ". The dont_report_yourself reporter has the following configuration parameters:" do          
    #    it "threshold, the threshold of number of lines which should be reported as duplication, default is #{DontRepeatYourself::Reporter::DEFAULT_THRESHOLD} " do
    #      @reporter.duplicate_lines_threshold.should == 
    #    end  
    
    it "You should configure the report parameters through a dont_repeat_yourself.yml file in the conf folder" do
      pending("configuration parameters")
      #      @reporter.with_duplicate_lines_threshold=(DontRepeatYourself::Reporter::DEFAULT_THRESHOLD)
      # TODO install reporter should copy the default dont_repeat_yourself.yml
    end  
    
    it "should configure_simian_for_current_rails_project " do    
      @reporter.configure_simian_for_current_rails_project
      # TODO Write spec. Using mocks?
     @reporter.simian_runner.basedir.should == File.expand_path(RAILS_ROOT)
    end
    
  end 
  
  describe ". The 'Duplicate lines' report generation process:" do    
    
    it "should run the simian program" do
      @reporter.configure_simian_for_current_rails_project
      @reporter.run_simian
    end        
            
    DontRepeatYourself::REPORT_TYPES.each{|report_type|                        
      it "should run simian and generate the #{report_type} report for any type of project" do
        @reporter.simian_runner.basedir = File.expand_path(RAILS_ROOT)
        @reporter.simian_runner.add_ruby_directory_to_search_for_duplicate_lines("app")
        @reporter.send(report_type.downcase + "_report")
      end
      
      it "should run simian and generate the #{report_type} report for the Rails project where the reporter is installed" do
        @reporter.configure_simian_for_current_rails_project
        @reporter.send(report_type.downcase + "_rails_report")
      end          
    }       
  end
  
  describe "(Eating its own dog food ;-)" do
    it { ruby_code_in_rails_plugin("dont_repeat_yourself").
            with_threshold_of_duplicate_lines(2).
              with_netbeans_reporting.
                should be_DRY }      
  end
  
end