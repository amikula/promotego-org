require 'dont_repeat_yourself'

module DontRepeatYourself
  
  module UnitTestingHelpers
  
    # TODO Refactoring move this to dont_repeat_yourself
    class ProjectBase
      attr_accessor :report_type, :expected_number_of_duplicate_lines
      def initialize(name)
        @name = name
        @dry = DontRepeatYourself::Reporter.new
        
        # Default values
        @expected_number_of_duplicate_lines = 0
        @report_type = DontRepeatYourself::DEFAULT_REPORT                
      end      
      
      # Fluent interface
      def with_threshold_of_duplicate_lines(threshold)
        @dry.simian_runner.threshold = threshold        
        return self
      end
      
      def with_netbeans_reporting
        @report_type = DontRepeatYourself::NETBEANS_REPORT
        return self
      end
      
      def is_DRY?
        @dry.run_simian
        @dry.simian_results.duplicate_line_count <= @expected_number_of_duplicate_lines        
      end
      
      def failure_message
        # TODO Replace this line by a report() ?
        report = @dry.send(@report_type.downcase + "_report")        
        "expected #{@name} to have less or equal #{@expected_number_of_duplicate_lines} duplicate lines :\n
         DRY Report:\n#{report}\n"
      end
    end
    
    # TODO will not work, write spec
    class RubyProject < ProjectBase
      def initialize(project_path)
        super(project_name)
        @dry.configure_simian_for_ruby_project(@project_name)
      end
    end
    
    class RailsProject < ProjectBase
      def initialize       
        super("your Rails application")        
        @dry.configure_simian_for_current_rails_project
      end
    end
  
    class RailsPluginProject  < ProjectBase
      def initialize(plugin_name)
        super(plugin_name )
        @dry.configure_simian_for_rails_plugin(plugin_name)
      end            
    end  
    
    # Too tired to give a meaningfull name now
    module XXXHelpers
      # Helpers
      def ruby_code_in_rails_plugin(plugin_name)
        DontRepeatYourself::UnitTestingHelpers::RailsPluginProject.new(plugin_name)
      end
    
      def rails_application
        DontRepeatYourself::UnitTestingHelpers::RailsProject.new
      end
    end
    # Test::Unit extension

    module TestUnitExtension
      include DontRepeatYourself::UnitTestingHelpers::XXXHelpers
      
      def assert_DRY(project)
        assert(project.is_DRY?, project.failure_message)
      end
    
    end   

    # RSpec Custom Matcher

    module RSpecMatchers
      
      include DontRepeatYourself::UnitTestingHelpers::XXXHelpers
      
      class BeDRY
                              
        def matches?(project)
          @project = project
          project.is_DRY?
        end
        
        # TODO Do we really need this? It does not make a lot of sense
        def negative_failure_message
          "expected #{@project.name} to have more than #{@project.expected_number_of_duplicate_lines} duplicate lines :\n but found the following:\n "
        end
      
        def description
          "be DRY\n" << "  - with a threshold of #{@threshold} duplicate lines"
        end
        
        def failure_message
          @project.failure_message
        end
    
      end        
    
      # Custom expectation matcher
      def be_DRY
        DontRepeatYourself::UnitTestingHelpers::RSpecMatchers::BeDRY.new
      end                          
    
    end
  end
end

# Automatically includes assert_*
module Test
  module Unit
    class TestCase #:nodoc:
      include DontRepeatYourself::UnitTestingHelpers::TestUnitExtension
    end
  end
end

# Add this matcher to RSpec default matchers
module Spec
  module Rails
    module Matchers     
      include DontRepeatYourself::UnitTestingHelpers::RSpecMatchers
    end
  end
end