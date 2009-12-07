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
    geminstaller = YAML.load(File.new('config/geminstaller.yml'))
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
    print 'Writing reverse countries...'
    I18n.available_locales.each do |locale|
      countries_hash = I18n.t('countries', :locale => locale)

      # Only continue if the locale of the translation matches our locale, ie, if there was no fallback translation
      if locale == countries_hash.first.last.locale
        new_data = {locale => {:reverse_countries => Hash[*countries_hash.invert.map{|k,v| [k.to_sym, v.to_s]}.flatten]}}
        print "#{locale}..."

        # Make sure the directory exists
        FileUtils.mkdir_p(File.join(Rails.root, 'lib', 'locale', locale.to_s))

        # Write the reverse data to the file
        File.open(File.join(Rails.root, 'lib', 'locale', locale.to_s, 'reverse_countries.rb'), 'w') do |file|
          file << new_data.inspect
          file << "\n"
        end
      end
    end

    print "\n"
  end
end
