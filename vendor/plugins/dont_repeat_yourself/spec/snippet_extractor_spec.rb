require File.dirname(__FILE__) + '/spec_helper'
require "dont_repeat_yourself/snippet_extractor"

describe DontRepeatYourself::SnippetExtractor do
  
  before :each do 
    @snippet_extractor = DontRepeatYourself::SnippetExtractor.new
  end
  
 it "should extract the plaint text source code from the file when specifying a file, a start and and an end line" do
    expected_source = "  before :each do 
    @snippet_extractor = DontRepeatYourself::SnippetExtractor.new
  end"
    
    @snippet_extractor.plain_source_code(6, 8, File.dirname(__FILE__) + "/snippet_extractor_spec.rb").should == expected_source
  end  
  
  it "should use the syntax gem to output the code with syntax highlighting" do
    @snippet_extractor.snippet(1, 36, File.dirname(__FILE__) + "/snippet_extractor_spec.rb")
  end
  
end