# Install hook code here
begin
  require 'rubygems'
  require 'syntax/convertors/html'
  
rescue LoadError => e
  puts "**********************************************************************************"  
  puts "WARNING: You see this message because you haven't installed the 'syntax' gem."
  puts "Run 'gem install syntax' to get syntax highlighting"      
  puts "**********************************************************************************"  

end
    
# TODO Uncomment this when the dry.yml is set up ...
# puts "Copying the default dry.yml configuration file to your config folder"
