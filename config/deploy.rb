set :application, 'promotego-org'
set :domain, 'webapps@promotego.org'
set :deploy_to, '/var/tmp/promotego-vlad'
set :repository, 'git://github.com/amikula/promotego-org.git'
set :app_command, "/usr/sbin/apache2ctl"

namespace :vlad do
  desc 'Restart Passenger'
  remote_task :start_app, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc 'Restarts the apache servers'
  remote_task :start_web, :roles => :app do
    run "sudo #{app_command} restart"
  end

  ### Extending 'vlad:update' with 'gems:geminstaller'
  desc "Install gems via geminstaller."
  remote_task :update, :roles => :app do
    Rake::Task['gems:geminstaller'].invoke
  end
end

namespace :gems do
  desc "Run geminstaller."
  remote_task :geminstaller, :roles => :app do
    run "cd #{current_path}; sudo geminstaller"
  end
end
