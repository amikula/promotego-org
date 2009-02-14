namespace :app do
  desc 'Load roles from config/roles.yml'
  task :load_roles => :environment do
    Role.load_roles(File.new('config/roles.yml'))
  end
end
