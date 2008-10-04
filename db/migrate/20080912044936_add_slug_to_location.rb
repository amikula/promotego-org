class AddSlugToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :slug,:string
  end

  def self.down
    remove_column :locations, :slug
  end
end
