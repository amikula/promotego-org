require File.dirname(__FILE__) + '/simian_runner'
require File.dirname(__FILE__) + '/simian_results'
require File.dirname(__FILE__) + '/snippet_extractor'
require File.dirname(__FILE__) + '/formatter'

module DontRepeatYourself
  
  # TODO Use an enum gem / plugin here?
  DEFAULT_REPORT, HTML_REPORT, NETBEANS_REPORT, TEXTMATE_REPORT = "Default", "HTML", "Netbeans", "TextMate"    
  REPORT_TYPES = [DEFAULT_REPORT, NETBEANS_REPORT, HTML_REPORT, TEXTMATE_REPORT]    
  
  class Reporter    
    attr_reader :simian_log_file,
      :simian_runner,
      :simian_results,
      :project_name
    
    # TODO Improve: is there a way of doing some clean Dependency Injection without dependency?
    def initialize()
      @simian_runner = DontRepeatYourself::SimianRunner.new      
    end                             
    
    ### Define methods for generating a DRY *_report for any Ruby project
    REPORT_TYPES.each do |report_type|
      define_method("#{report_type.downcase}_report") do        
        simian_results = run_simian        
        return DontRepeatYourself::FormatterFactory.create_report(report_type, simian_results)
      end
    end
    
    ### Define methods for generating a DRY *_rails_report for Rails project where plugin is installed
    DEFAULT_REPORT_DESC   = "display the default plain report"    
    NETBEANS_REPORT_DESC  = "display the report in the Output window of the Netbeans IDE (Ctrl+4)"    
    HTML_REPORT_DESC      = "generate an DRY_report.html file in the project root folder"    
    TEXTMATE_REPORT_DESC  = "to generate an html report with links which open files in the Textmate editor" 
    
    [DEFAULT_REPORT, NETBEANS_REPORT].each do |report_type|
      define_method("#{report_type.downcase}_rails_report") do                
        puts generate_report_for_rails_project(report_type)
      end
    end
    
    [HTML_REPORT, TEXTMATE_REPORT].each do |report_type|
      define_method("#{report_type.downcase}_rails_report") do        
        report = generate_report_for_rails_project(report_type)
        open(@simian_html_report, 'w') { |f| f << report } 
      end
    end
    
    # protected ?        
    
    ### Configuration methods
    def generate_report_for_rails_project(report_type)
      configure_simian_for_current_rails_project
      return self.send("#{report_type.downcase}_report")
    end
    
    # TODO write spec
    def configure_simian_for_ruby_project(project_path)            
      @simian_runner.basedir = project_path
      @simian_runner.add_ruby_directory_to_search_for_duplicate_lines("lib")             
      
      @project_name = project_basename
    end
    
    # TODO write spec
    def configure_simian_for_rails_plugin(plugin_name)            
      @simian_runner.basedir = RAILS_ROOT + "/vendor/plugins/" + plugin_name      
      @simian_runner.add_ruby_directory_to_search_for_duplicate_lines("lib")             
      
      @project_name = project_basename + " plugin"
    end
    
    # TODO write spec
    def configure_simian_for_current_rails_project            
      @simian_runner.basedir = File.expand_path(RAILS_ROOT)      
      @simian_runner.add_ruby_directory_to_search_for_duplicate_lines("app")
      @simian_runner.add_ruby_directory_to_search_for_duplicate_lines("lib")
      @simian_runner.add_ruby_directory_to_search_for_duplicate_lines("spec")
      @simian_runner.add_html_directory_to_search_for_duplicate_lines("app/views")
      
      @simian_html_report = RAILS_ROOT + "/DRY_report.html"      
      
      @project_name = project_basename + " Rails application"
    end                  
    
    def run_simian      
      results_in_yaml_format = @simian_runner.run      
      @simian_results = DontRepeatYourself::SimianResults.new(results_in_yaml_format) 
      @simian_results
    end
    
    # These methods should not be called from the outside
    ################################################
    private        
    
    def project_basename
      Pathname.new(@simian_runner.basedir).basename
    end        
        
  end    
  
end
