class UpdateSlugInfo < ActiveRecord::Migration
  def self.up
    locations = Location.find(:all)
    locations.each do |location|
      if location.update_attribute(:slug,location.sluggify)
        puts "Saved : #{location.slug}"
      else
        puts "filed : #{location.slug}"
      end
    end
  end

  def self.down
    locations = Location.find(:all)
    locations.each do |location|
      location.update_attribute(:slug,'')
    end
  end
end
