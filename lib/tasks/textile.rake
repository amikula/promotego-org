namespace :textile do
  desc 'Replace html <br> tags in club descriptions with newlines for textile compatibility'
  task :club_desc => :environment do
    puts 'Updating club descriptions...'
    count = 0
    updated = 0
    Location.find_each do |loc|
      # Only operate on imported locations
      d = loc.description
      loc.description = d # reinsert the description, replacing all <br> tags
      if d != loc.description
        puts "before: #{loc.description}"
        puts "after: #{d}"
        update += 1
      end
      loc.save(false) || raise("Error updating club #{loc.name}")
      count += 1
    end
    puts "Updated #{updated} of #{count}."
  end
end
