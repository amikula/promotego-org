require 'highline/import'

namespace :app do
  desc 'Load roles from config/roles.yml'
  task :load_roles => :environment do
    Role.load_roles(File.new('config/roles.yml'))
    puts "Loaded roles"
  end

  desc 'Create owner account'
  task :create_owner => :environment do
    puts "\nEnter info for default owner:"
    CommandLineUtil.create_user(:owner)
  end

  desc 'Create initial affiliates'
  task :create_affiliates => :environment do
    unless Affiliate.find_by_name('AGA')
      Affiliate.create!(:name => 'AGA', :full_name => 'American Go Association',
                        :logo_path => '/affiliate_logos/agalogo.gif')
    end
  end

  desc 'Initialize application data (roles, types, owner account)'
  task :initialize => [:load_roles, :create_affiliates, :create_owner]
end
