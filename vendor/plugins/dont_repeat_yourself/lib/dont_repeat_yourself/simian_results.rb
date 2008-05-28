module DontRepeatYourself
  class SimianResults
    attr_reader :duplicate_file_count,
      :duplicate_line_count,
      :duplicate_block_count,
      :total_significant_line_count,
      :total_raw_line_count, 
      :total_file_count,
      :sets
    
    def initialize(simian_log_yaml)
      @simian_log_yaml = simian_log_yaml
    
      @duplicate_file_count = summary['duplicateFileCount']
      @duplicate_line_count = summary['duplicateLineCount']
      @duplicate_block_count = summary['duplicateBlockCount']
      
      @total_significant_line_count = summary['totalSignificantLineCount']
      @total_raw_line_count = summary['totalRawLineCount']
      @total_file_count = summary['totalFileCount']      
      
      sets =@simian_log_yaml["simian"]["checks"][0]["sets"]
      if sets.nil?
        @sets = []
      else
        @sets = @simian_log_yaml["simian"]["checks"][0]["sets"].collect{ |original_set|
          DontRepeatYourself::SimianResults::DuplicateLinesSet.new(original_set)
        }  
      end      
    end    
    
    #    ignoreCurlyBraces		false	boolean	Curly braces are ignored.
    #ignoreIdentifiers		false	boolean	Completely ignores all identfiers.
    #ignoreIdentifierCase		true	boolean	Matches identifiers irrespective of case. Eg. MyVariableName and myvariablename would both match.
    #ignoreStrings		false	boolean	MyVariable and myvariablewould both match.
    #ignoreStringCase	J	true	boolean	"Hello, World" and "HELLO, WORLD" would both match.
    #ignoreNumbers		false	boolean	int x = 1; and int x = 576; would both match.
    #ignoreCharacters		false	boolean	'A' and 'Z'would both match.
    #ignoreCharacterCase		true	boolean	'A' and 'a'would both match.
    #ignoreLiterals		false	boolean	'A', "one" and 27.8would all match.
    #balanceParentheses		false	boolean	Ensures that expressions inside parenthesis that are split across multiple physical lines are considered as one.
    #balanceCurlyBraces		false	boolean	Ensures that expressions inside curly braces that are split across multiple physical lines are considered as one.
    #balanceSquareBrackets		false	boolean	Ensures that expressions inside square brackets that are split across multiple physical lines are considered as one. Defaults to false.
    
    def sentence_found_x_duplicate_lines_in_y_blocks_in_z_files
      "Found #{self.duplicate_line_count} duplicate lines in #{self.duplicate_block_count} blocks in #{self.duplicate_file_count} files"
    end
    
    def sentence_processed_a_total_of_x_significant_lines_in_y_files
      "Processed a total of #{self.total_significant_line_count} significant (#{self.total_raw_line_count} raw) lines in #{self.total_file_count} files"
    end 
    
    class DuplicateLinesSet
      attr_reader :number_of_duplicate_lines, :blocks
      def initialize(original_set)
        @number_of_duplicate_lines = original_set["lineCount"]
        @blocks = original_set["blocks"].collect{ |original_block|
          DontRepeatYourself::SimianResults::DuplicateLinesBlock.new(original_block)
        }      
      end      
      
      def sentence_found_x_duplicate_lines_in_the_following_files
        "Found #{@number_of_duplicate_lines} duplicate lines in the following files:"
      end                  
    
    end
    
    class DuplicateLinesBlock
      attr_reader :line_number_of_first_duplicate_line,
        :line_number_of_last_duplicate_line,
        :file_path
      
      def initialize(original_block)
        @line_number_of_first_duplicate_line = original_block["startLineNumber"]
        @line_number_of_last_duplicate_line = original_block["endLineNumber"]
        @file_path = original_block["sourceFile"]
      end  

      def sentence_between_lines_x_and_y_in_filepath
        "Between lines #{self.line_number_of_first_duplicate_line} and #{self.line_number_of_last_duplicate_line} in #{self.file_path}"
      end      
    end        
    
    private
    
    def summary
      @simian_log_yaml["simian"]["checks"][0]["summary"]
    end
        
  end
end
