require File.dirname(__FILE__) + '/spec_helper'
require "dont_repeat_yourself/simian_results"

describe DontRepeatYourself::SimianResults do                     
  
  describe "(when parsing a project which does not contain any duplicate lines (yes it does exist!!!) )" do
        
    it "should not parse the 'sets' structure because it will be empty" do
      simian_log_when_0_duplicate_lines = <<END_OF_STRING
simian:        
  version: "2.2.22"
  checks:
    - failOnDuplication: true
      ignoreCharacterCase: true
      ignoreCurlyBraces: true
      ignoreIdentifierCase: true
      ignoreModifiers: true
      ignoreStringCase: true
      threshold: 2
      sets:
      summary:
        duplicateFileCount: 0
        duplicateLineCount: 0
        duplicateBlockCount: 0
        totalFileCount: 0
        totalRawLineCount: 0
        totalSignificantLineCount: 0
        processingTime: 15
END_OF_STRING
      DontRepeatYourself::SimianResults.new(YAML.load(simian_log_when_0_duplicate_lines))
    end
    
  end
  
  describe "(after parsing)" do
    
    before :each do       
      yaml_result_string = IO.read(File.dirname(__FILE__) + "/full_simian_log.yaml")
      yaml_results = YAML.load(yaml_result_string)
      @results = DontRepeatYourself::SimianResults.new(yaml_results)
    end    
    
    # def a simple matcher we can use for attributes
    def have_attribute(attribute, value)
      return simple_matcher("have attribute '#{attribute.humanize}' ")  do |results| 
        (results.send(attribute)) == value
      end        
    end
    
    it { @results.should have_attribute("total_significant_line_count", 7031) }
    it { @results.should have_attribute("total_raw_line_count", 11191) }
    it { @results.should have_attribute("total_file_count", 249) }        
       
    it "should generate the #{"".humanize}" do 
      pending("TODO explanation of parameters and list of folders loaded")
      #      @results.sentence_.should ==
      #        "{failOnDuplication=true, ignoreCharacterCase=true, ignoreCurlyBraces=true, ignoreIdentifierCase=true, ignoreModifiers=true, ignoreStringCase=true, threshold=5}
      #Loading (recursively) *.rb from /home/jeanmichel/ruby/projects/21croissants_plugins/app"
    end
    
    it "should generate the #{"sentence_processed_a_total_of_x_significant_lines_in_y_files".humanize}" do 
      @results.sentence_found_x_duplicate_lines_in_y_blocks_in_z_files.should ==
        "Found 889 duplicate lines in 86 blocks in 50 files"
    end    
        
    it "should generate the #{"sentence_processed_a_total_of_x_significant_lines_in_y_files".humanize}" do 
      @results.sentence_processed_a_total_of_x_significant_lines_in_y_files.should ==
        "Processed a total of 7031 significant (11191 raw) lines in 249 files"
    end    
    
    describe DontRepeatYourself::SimianResults::DuplicateLinesSet do
      before :each do
        @first_set = @results.sets.first
      end
      it "should get the array of sets of duplicate lines from the report" do        
        @results.sets.should have(45).items
      end   
    
      it "should extract the number of duplicate lines from a set" do            
        @first_set.number_of_duplicate_lines.should == 6
      end   
    
      it "should get the array of blocks of duplicate lines from a set" do
        @first_set.blocks.should have(2).items
      end
      
      it "should generate the #{"sentence_found_x_duplicate_lines_in_the_following_files".humanize}" do 
        @first_set.sentence_found_x_duplicate_lines_in_the_following_files.should ==
          "Found 6 duplicate lines in the following files:"
      end
    end  
    
    describe DontRepeatYourself::SimianResults::DuplicateLinesBlock do
      before :each do
        @first_block = @results.sets.first.blocks.first
      end
      it "should extract the line number of the first duplicate line from a block" do        
        @first_block.line_number_of_first_duplicate_line.should == 37
      end
    
      it "should extract the line number of the last duplicate line from a block" do    
        @first_block.line_number_of_last_duplicate_line.should == 44
      end
    
      it "should extract the filepath of the file which contains duplicates lines from a block" do    
        @first_block.file_path.should include("/app/views/layouts/z-not-used/_recommend_linqia_bar.rhtml")
      end   
      
      it "should generate the #{"sentence_between_lines_x_and_y_in_filepath".humanize}" do 
        @first_block.sentence_between_lines_x_and_y_in_filepath.should ==
          "Between lines 37 and 44 in /home/jeanmichel/ruby/projects/linqia_portal/config/../app/views/layouts/z-not-used/_recommend_linqia_bar.rhtml"
      end
    end
    
  end
      
end
