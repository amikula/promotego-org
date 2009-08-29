set :application, 'promotego-org'
set :domain, 'webapps@promotego.org'
set :deploy_to, '/var/webapps/vlad/promotego'
set :repository, 'git://github.com/amikula/promotego-org.git'
set :app_command, "/usr/sbin/apache2ctl"

namespace :vlad do
  desc 'Restart Passenger'
  remote_task :start_app, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  Rake.clear_tasks('vlad:start_web')
  desc 'Restarts the apache servers'
  remote_task :start_web, :roles => :web do
    run "sudo #{app_command} restart"
  end

  ### Extending 'vlad:update' with 'gems:geminstaller' and stuff
  desc "Update hooks."
  remote_task :update, :roles => :app do
    run "cp #{current_path}/config/database_init.yml #{current_path}/config/database.yml"
    Rake::Task['gems:geminstaller'].invoke
    Rake::Task['whenever:update'].invoke
  end
end

namespace :gems do
  desc "Run geminstaller."
  remote_task :geminstaller, :roles => :app do
    run "cd #{current_path}; sudo geminstaller"
  end
end
