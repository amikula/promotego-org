class AddParentIdToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :parent_id, :integer

    %w{owner super_user administrator}.inject(nil) do |parent,current|
      role = Role.find_by_name(current)
      role.parent = parent
      role.save!

      role
    end
  end

  def self.down
    remove_column :roles, :parent_id
  end
end
