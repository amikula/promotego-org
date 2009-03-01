require 'highline/import'

namespace :app do
  desc 'Load roles from config/roles.yml'
  task :load_roles => :environment do
    Role.load_roles(File.new('config/roles.yml'))
  end

  desc 'Load default types'
  task :load_types => :environment do
    ["Go Club", "Coffee House", "Park", "Pub", "Other"].each do |type|
      Type.create(:name => type) unless Type.find_by_name(type)
    end
  end

  desc 'Create owner account'
  task :create_owner => :environment do
    CommandLineUtil.create_user(:owner)
  end

  desc 'Initialize application data (roles, types, owner account)'
  task :initialize => [:load_roles, :load_types, :create_owner]
end