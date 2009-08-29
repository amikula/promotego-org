task :whenever do
  require 'whenever'

  Whenever::CommandLine.execute
end

namespace "whenever" do
  desc "Update crontab file"
  task :update do
    require 'whenever'

    Whenever::CommandLine.execute(:update => true, :identifier => "promotego")
  end
end
