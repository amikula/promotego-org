class RemoveIsAgaFromLocations < ActiveRecord::Migration
  def self.up
    remove_column :locations, :is_aga
  end

  def self.down
    add_column :locations, :is_aga
  end
end
