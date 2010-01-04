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

  desc 'Print the application environment'
  task :printenv do
    ENV.each_pair do |k,v|
      puts "#{k}=#{v}"
    end
  end

  desc 'Update .gems for heroku based on geminstaller.yml'
  task :update_dotgems do
    geminstaller = YAML.load(ERB.new(File.read('config/geminstaller.yml')).result)
    File.open('.gems', 'w') do |f|
      geminstaller['gems'].each do |gemspec|
        line = gemspec['name']
        line << " --version '#{gemspec['version']}'" if gemspec['version']
        line << "\n"
        f << line
      end
    end
  end

  desc 'Reverse country translations'
  task :reverse_countries => :environment do
    ReverseTranslations.do_reverse('countries')
  end

  desc 'Reverse province translations'
  task :reverse_provinces => :environment do
    ReverseTranslations.do_reverse('provinces')
  end
end
