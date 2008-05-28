require 'yaml'

module DontRepeatYourself
  
  # See Simian doc in http://www.redhillconsulting.com.au/products/simian/installation.html#cli
  class SimianRunner
    
    attr_reader :basedir,
                :patterns_of_directories_to_search_for_duplicate_lines,
                :formatter_option,
                :simian_jar_path,
                :executable,
                :simian_log_file,
                :threshold
    
    DEFAULT_THRESHOLD = 3
    
    def initialize()
      @threshold = DEFAULT_THRESHOLD
      @patterns_of_directories_to_search_for_duplicate_lines = []
      @formatter_option = "-formatter=yaml"
      
      # extension is .txt because the selenium_on_rails project had a problem with jar files that could be
      # downloaded from the rubygems repository
      # In order to prevent this kind of problem, I decided to use another suffix as they did ...
      @simian_jar_path = File.join(File.dirname(__FILE__), '..', 'jars', 'simian-2.2.22.jar.txt')
      
      @executable = "java -jar #{@simian_jar_path}".freeze
      
      @simian_log_file = RAILS_ROOT + "/simian_log.yaml"
    end
    
    def threshold=(threshold)
      raise ArgumentError.new("Error: Threshold can't be less that 2") if threshold < 2
      @threshold = threshold
    end
    
    def basedir=(basedir)
      # TODO Check if Validatable has some generic code for this. I keep copy-pasting here !!!
      raise ArgumentError.new(basedir << " does not exist") if !File.directory?(basedir)
      @basedir = basedir
    end
    
    def add_ruby_directory_to_search_for_duplicate_lines(path)
      valid_path(path)
      @patterns_of_directories_to_search_for_duplicate_lines << (path + "/**/*.rb")
    end       
    
    def add_html_directory_to_search_for_duplicate_lines(path)
      valid_path(path)
      @patterns_of_directories_to_search_for_duplicate_lines << (path + "/**/*.*html")
    end               
    
    def run      
      run_java
      results_yaml = YAML.load(simian_output_with_header_removed)
      delete_simian_log_file
      results_yaml
    end        
    
    private
    
    def parameter_threshold
      "-threshold=#{@threshold}"
    end
    
    def parameter_includes
      @patterns_of_directories_to_search_for_duplicate_lines.map { |pattern| 
        "-includes=#{File.join(@basedir, pattern)}" 
      } * ' '
    end   
    
    def command_line
      "#{@executable} #{parameter_threshold} #{@formatter_option} #{parameter_includes} > #{@simian_log_file}"
    end
    
    # TODO Add return code processing
    def run_java
      system(command_line)
    end
    
    def simian_output_with_header_removed
      # Remove the Simian text header
      log = IO.read(@simian_log_file)
      header_to_remove = "Similarity Analyser 2.2.22 - http://www.redhillconsulting.com.au/products/simian/index.html\nCopyright (c) 2003-08 RedHill Consulting Pty. Ltd.  All rights reserved.\nSimian is not free unless used solely for non-commercial or evaluation purposes.\n---\n"
      cleaned_yaml = log.gsub(header_to_remove, '')            
      cleaned_yaml
    end
    
    def delete_simian_log_file
      File.delete @simian_log_file if File.file?(@simian_log_file)
    end
    
    def valid_path(path)
      absolute_path = File.join(@basedir, path)
      if !File.directory?(absolute_path)
        raise ArgumentError.new(absolute_path << " does not exist, path should be relative to #{@basedir} and not start neither end with '/' ") 
      end
      absolute_path
    end        
    
  end
  
end