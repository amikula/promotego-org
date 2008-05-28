require File.dirname(__FILE__) + '/simian_results'

module DontRepeatYourself    
  
  class FormatterFactory    
        
    # TODO Use a kind of Dependency Injection here, the plugin should not know about this class
    @@snippet_extractor = DontRepeatYourself::SnippetExtractor.new    
    
    def self.create_report(report_type, simian_results)
      formatter_class = DontRepeatYourself.const_get("#{report_type}Formatter")        
      return formatter_class.new(@@snippet_extractor, simian_results).report
    end
  end
  
  class DefaultFormatter
    
    attr_reader :simian_results
    
    # Inject dependency thtough 
    def initialize(snippet_extractor, simian_results)
      @snippet_extractor = snippet_extractor
      @simian_results = simian_results
    end
    
    def report
      report_body.gsub(/TWO_SPACE_CHARS/, "  ")      
    end  
    
    # Protected methods to be used by formatters 
    #    protected            
    
    def report_body
      body = ""
      body << @simian_results.sentence_processed_a_total_of_x_significant_lines_in_y_files << "\n"
      body << @simian_results.sentence_found_x_duplicate_lines_in_y_blocks_in_z_files << "\n\n"      
      @simian_results.sets.each{|set|
        body << set.sentence_found_x_duplicate_lines_in_the_following_files << "\n"        
        set.blocks.each{ |block|
          body << "TWO_SPACE_CHARS" << format_sentence_between_lines_x_and_y_in_filepath(block) << "\n"          
        }
        body << "TWO_SPACE_CHARS" << format_duplicate_lines_snippet(set.blocks.last) << "\n"         
      }
      body
    end
    
    # Default, return the sentence
    def format_sentence_between_lines_x_and_y_in_filepath(block)
      block.sentence_between_lines_x_and_y_in_filepath 
    end
    
    def format_duplicate_lines_snippet(block)
      snippet = "Duplicate lines:\n"      
      snippet << @snippet_extractor.plain_source_code(block.line_number_of_first_duplicate_line, block.line_number_of_last_duplicate_line, block.file_path)
    end                
               
  end
  
  class NetbeansFormatter < DefaultFormatter          
    def format_sentence_between_lines_x_and_y_in_filepath(block)
      block.sentence_between_lines_x_and_y_in_filepath << ":#{block.line_number_of_first_duplicate_line}:" 
    end    
  end
  
  class HTMLFormatter < DefaultFormatter
    
    def report
      report = report_header          
      report << report_body.gsub(/TWO_SPACE_CHARS/, "&nbsp;&nbsp;").gsub(/\n/, "</br>\n")           
      report << report_footer
    end
           
    def format_duplicate_lines_snippet(block)
      starts = block.line_number_of_first_duplicate_line
      ends = block.line_number_of_last_duplicate_line
      file_path = block.file_path      
      html_source_code = @snippet_extractor.snippet(starts, ends, file_path)
        
      source_id = "#{File.basename(file_path)}_#{starts}_#{ends}"
      source_code_div  = "        <div>&nbsp;&nbsp;[<a id=\"l_#{source_id}\" href=\"javascript:toggleSource('#{source_id}')\">Show duplicate lines source code</a>]</div>"
      source_code_div << "        <div id=\"#{source_id}\" class=\"dyn-source\"><pre class=\"ruby\"><code>#{html_source_code}</code></pre></div>"     
    end  
    
    # TODO use erb to generate the report?
    def get_asset(asset)
      IO.read(File.dirname(__FILE__) + '/../assets/' + asset)
    end
    
    def report_header
      global_scripts = get_asset('dry.js')
      global_styles = get_asset('/dry.css')
      # TODO use erb.html ;-)  
      <<-EOF
<html>
<head>
<script type="text/javascript">
    // <![CDATA[
#{global_scripts}
    // ]]>
  </script>
  <style type="text/css">
#{global_styles}
  </style>
</head>

<body>
<div class="rspec-report">
  
<div id="rspec-header">
  <h1>Don't Repeat Yourself report Result</h1>  
</div>

<div class="results">
      EOF
    end
            
    def report_footer
      <<-EOF
          </div>
        </div>
      </body>
    </html>
      EOF
    end  
  end    
  
  class TextMateFormatter < HTMLFormatter           
    
    def format_sentence_between_lines_x_and_y_in_filepath(block)
      starts = block.line_number_of_first_duplicate_line
      file_path = block.file_path
      sentence = block.sentence_between_lines_x_and_y_in_filepath 
      "<a href='txmt://open?url=file://#{file_path}&line=#{starts}'>#{sentence}</a>"            
    end
    
  end    
  
end