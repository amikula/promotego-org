class AddHiddenToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :hidden, :boolean
  end

  def self.down
    remove_column :locations, :hidden
  end
end
