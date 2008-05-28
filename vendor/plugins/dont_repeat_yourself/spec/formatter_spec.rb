require File.dirname(__FILE__) + '/spec_helper'
require "dont_repeat_yourself/formatter"

describe "Report formatters:\n" do

  before :each do 
    # TODO Test in Isolation =>  Mock DontRepeatYourself::SnippetExtractor.new
    @snippet_extractor = DontRepeatYourself::SnippetExtractor.new   
    yaml_result_string = IO.read(File.dirname(__FILE__) + "/dummy_simian_log.yaml")
    yaml_results = YAML.load(yaml_result_string)
    @simian_results = DontRepeatYourself::SimianResults.new(yaml_results)
    
    @formatter = DontRepeatYourself::DefaultFormatter.new(@snippet_extractor, @simian_results)    
  end                    
  
  describe DontRepeatYourself::DefaultFormatter do
                                                     
    # TODO Mock DontRepeatYourself::SnippetExtractor to avoid the
    # Couldn't get snippet for /home/jeanmichel/ruby/projects/21croissants_plugins/config/../app/models/dummy_model2.rb
    it "should generate a report body" do 
      expected_default_body = <<END_OF_STRING
Processed a total of 19 significant (37 raw) lines in 4 files
Found 12 duplicate lines in 2 blocks in 2 files

Found 6 duplicate lines in the following files:
TWO_SPACE_CHARSBetween lines 4 and 9 in /home/jeanmichel/ruby/projects/dryplugin/config/../app/models/dummy_model.rb
TWO_SPACE_CHARSBetween lines 5 and 10 in /home/jeanmichel/ruby/projects/dryplugin/config/../app/models/dummy_model2.rb
TWO_SPACE_CHARSDuplicate lines:
    puts "a bit of dupplicate lines"
    puts "a bit of dupplicate lines"
    puts "a bit of dupplicate lines"
    puts "a bit of dupplicate lines"
    puts "a bit of dupplicate lines"
    puts "a bit of dupplicate lines"
END_OF_STRING
      #      puts @formatter.report_body
      @formatter.report_body.should == expected_default_body
    end  
          
  end

  describe "Custom formatters:\n" do    
    DontRepeatYourself::REPORT_TYPES.each{|report_type|      
      formatter_class = DontRepeatYourself.const_get("#{report_type}Formatter")
      describe formatter_class do
        before :each do
          @custom_formatter = formatter_class.new(@snippet_extractor, @simian_results)
        end
        
        it "should generate the #{report_type} report" do
          expected = IO.read(File.dirname(__FILE__) + "/expected/#{report_type}.html")
          #          puts @custom_formatter.report
          @custom_formatter.report.should == expected
        end    
      end
    }        

  end
  
  describe DontRepeatYourself::FormatterFactory do
    DontRepeatYourself::REPORT_TYPES.each{|report_type|      
      it "should create a #{report_type} formatter when report type = #{report_type}" do
        DontRepeatYourself::FormatterFactory.create_report(report_type, @simian_results).should_not be_nil
      end
    }
    
    it "should throw an error if the report type does not exist" do
      lambda { DontRepeatYourself::FormatterFactory.create_report("does not exist", @simian_results) }.should raise_error(NameError)      
    end 
    
  end
  
end
