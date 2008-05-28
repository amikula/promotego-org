require File.dirname(__FILE__) + '/../lib/dont_repeat_yourself'

namespace :dry do      
  namespace :report do
        
    DontRepeatYourself::REPORT_TYPES.each{|report_type|            
      desc eval("DontRepeatYourself::Reporter::#{report_type.upcase}_REPORT_DESC")
      task report_type.downcase do 
        reporter = DontRepeatYourself::Reporter.new
        reporter.send(report_type.downcase + "_rails_report")
      end            
    }
                    
  end
  
  desc 'Copy the DRYreport to the CruiseControl.rb build artefacts folder'
  task :cruise_control_artefact => "dry:report:html" do
    out = ENV['CC_BUILD_ARTIFACTS']
    system "mv DRY_report.html #{out}/"   
  end

end