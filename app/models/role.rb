class Role < ActiveRecord::Base
  acts_as_tree

  class << self
    def load_roles(data)
      roles = YAML.load(data)

      loaded_roles, saw_owner = initialize_roles(roles, nil)

      unless saw_owner
        owner = create_or_update_role('owner', nil)
        loaded_roles.each do |role|
          role.parent = owner
          role.save!
        end
      end
    end

    def initialize_roles(roles, parent)
      saw_owner = false

      return_roles = roles.collect do |role|
        case role
        when Hash
          key = role.keys.first
          saw_owner ||= (key == 'owner')

          this_role = create_or_update_role(key, parent)

          sub_owner = initialize_roles(role[key], this_role)[1]
          saw_owner ||= sub_owner
        else
          saw_owner ||= (role == 'owner')
          this_role = create_or_update_role(role, parent)
        end

        this_role
      end

      return return_roles, saw_owner
    end

    def create_or_update_role(name, parent)
      role = Role.find_by_name(name)
      if role
        if parent.nil? && role.parent != nil
          role.parent = nil
          role.save!
        elsif !parent.nil? && role.parent != parent
          role.parent = parent
          role.save!
        end

        return role
      else
        return Role.create!(:name => name, :parent => parent)
      end
    end
  end
end
