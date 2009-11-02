task :whenever do
  require 'whenever'
  require 'tempfile'

  Whenever::CommandLine.execute
end

namespace "whenever" do
  desc "Update crontab file"
  task :update do
    require 'whenever'
    require 'tempfile'

    Whenever::CommandLine.execute(:update => true, :identifier => "promotego")
  end
end
