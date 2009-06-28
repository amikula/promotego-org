class AddSourceIdToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :source_id, :integer
    add_column :locations, :foreign_key, :string
  end

  def self.down
    remove_column :locations, :source_id
    remove_column :locations, :foreign_key
  end
end
