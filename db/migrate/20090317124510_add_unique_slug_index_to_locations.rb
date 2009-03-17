class AddUniqueSlugIndexToLocations < ActiveRecord::Migration
  def self.up
    add_index :locations, :slug, :unique => true
  end

  def self.down
    remove_index :locations, :slug
  end
end
