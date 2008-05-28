require File.dirname(__FILE__) + '/spec_helper'
require "dont_repeat_yourself/simian_runner"

describe DontRepeatYourself::SimianRunner do
  
  before :each do 
    @runner = DontRepeatYourself::SimianRunner.new
  end    
  
  it "should allow to change the base directory to an existing directory" do    
    @runner.basedir= File.expand_path(RAILS_ROOT)
  end
  
  it "should have a default 'threshold' of 3" do    
    @runner.threshold.should == 3      
  end
  
  it "should have accessor to the 'threshold' attribute" do    
    @runner.threshold= 5      
  end
  
  it "should throw an error if 'threshold' < 2" do   
    lambda { @runner.threshold=1 }.should raise_error(ArgumentError)      
  end
  
  it "should validate presence of argument 'threshold' and checks it is a positive integer between 1 and 10" do    
    pending("use Validatable?")
  end
  
  describe "(when scanning for duplicate lines in a project)" do
    before :each do
      @runner.basedir = File.expand_path(RAILS_ROOT)
    end
    
    it "should have at least one ruby directory to search for duplicate lines" do    
      @runner.add_ruby_directory_to_search_for_duplicate_lines("app")     
    end
  
    it "should trown an Argument error if the specified directory does not exist" do    
      lambda { @runner.add_ruby_directory_to_search_for_duplicate_lines("nothing_here")  }.should raise_error(ArgumentError)      
    end
  
    it "should get the simian pattern (eg: 'app/**/*.rb') for each ruby directory (eg: 'app') to search for duplicate lines " do    
      @runner.add_ruby_directory_to_search_for_duplicate_lines("app") 
      @runner.patterns_of_directories_to_search_for_duplicate_lines[0].should == 'app/**/*.rb'
    end
  
    it "should trown an Argument error if no directory has been added" do    
      pending("To implement")
    end
    
    it "should generate the parameter '-includes' for the command line " do    
      @runner.add_ruby_directory_to_search_for_duplicate_lines("app") 
      @runner.add_html_directory_to_search_for_duplicate_lines("app/views") 

      class DontRepeatYourself::SimianRunner
        public(:parameter_includes)
      end    
      @runner.parameter_includes.should include("-includes=/")
      @runner.parameter_includes.should include("/app/**/*.rb")
      @runner.parameter_includes.should include("/views/**/*.*html")
      #   -includes=/home/jeanmichel/ruby/projects/21croissants_plugins/app/**/*.rb
    end
    
    describe "\When running simian:" do
      before :each do
        @runner.add_ruby_directory_to_search_for_duplicate_lines("app") 
        class DontRepeatYourself::SimianRunner
          public(:run_java, :simian_output_with_header_removed)
        end
      end

      it "should run successfully the java program Simian and write the result to a simian_log.yaml file " do            
        @runner.run_java
        File.file?(@runner.simian_log_file).should be_true    
      end
    
      it "should remove the Simian license header so the yaml file is well syntaxcly correct" do            
        @runner.run_java
      
        # TODO Remove the IO.read, encapsulate it! I never know if it's a string or a file (despite the suffix file!!!)
        log_file = @runner.simian_output_with_header_removed
        log_file.should_not include("Similarity Analyser 2.2.22 - http://www.redhillconsulting.com.au/products/simian/index.html")
        log_file.should_not include("Copyright (c) 2003-08 RedHill Consulting Pty. Ltd.  All rights reserved.")
        log_file.should_not include("Simian is not free unless used solely for non-commercial or evaluation purposes.")
        log_file.should_not include("---")        
    
        log_file.should include("summary")
      end
    
      it "should return the content of the simian yaml log file parsed into an Hash" do        
        @runner.run.should be_an_instance_of(Hash)
      end
    
      it "should delete the log file after the generation of the report" do
        @runner.run
        File.file?(@runner.simian_log_file).should be_false
      end  
    end
  end
  
  it "should output the result in yaml format" do    
    @runner.formatter_option.should == "-formatter=yaml"
  end
  
  it "should get the Simian jar path" do    
    @runner.simian_jar_path.should include("simian-2.2.22.jar.txt") 
  end
  
  it "should get the command line with the java executable" do    
    @runner.executable.should include("java -jar ") 
    @runner.executable.should include("simian-2.2.22.jar.txt") 
  end
  
  it "should throw an Argument Missing exception if the basedir is not specified" do        
    lambda { @runner.basedir = "some funky folder which does not exist"  }.should raise_error(ArgumentError)      
  end        
  
  it "should generate the parameter '-threshold' for the command line " do    
    class DontRepeatYourself::SimianRunner
      public(:parameter_threshold)
    end 
    @runner.parameter_threshold.should == "-threshold=3"
  end          
  
  it "should report the error of Simian if there is a problem " do    
    pending("TODO write spec")      
  end
      
  
end