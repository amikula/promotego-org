class AddParentIdToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :parent_id, :integer
  end

  def self.down
    remove_column :roles, :parent_id
  end
end
