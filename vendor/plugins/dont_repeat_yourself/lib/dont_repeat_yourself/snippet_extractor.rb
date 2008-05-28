module DontRepeatYourself    
  
  class SnippetExtractor #:nodoc:
    class NullConverter; def convert(code, pre); code; end; end #:nodoc:
    begin; require 'rubygems'; require 'syntax/convertors/html'; @@converter = Syntax::Convertors::HTML.for_syntax "ruby"; rescue LoadError => e; @@converter = NullConverter.new; end
    
    def plain_source_code(starts, ends, file_path)
      if File.file?(file_path)
        lines = File.open(file_path).read.split("\n")      
        lines[starts-1..ends-1].join("\n")
      else
        "# Couldn't get snippet for #{file_path}"
      end        
    end
        
    def snippet(starts, ends, file_path)      
      raw_code = plain_source_code(starts, ends, file_path)
      highlighted = @@converter.convert(raw_code, false)
      highlighted << "\n<span class=\"comment\"># gem install syntax to get syntax highlighting</span>" if @@converter.is_a?(NullConverter)      
      highlighted
    end            
                     
  end
  
end