begin
  extdir = File.join(Rails.root, 'lib', 'ext')

  Dir.foreach(extdir) do |file|
    next unless file =~ /.*\.rb$/
    require File.join(extdir, file)
  end
end
