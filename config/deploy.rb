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
end
