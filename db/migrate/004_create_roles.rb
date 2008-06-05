class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end

    Role.new(:name => "owner").save!
    Role.new(:name => "super_user").save!
    Role.new(:name => "administrator").save!
  end

  def self.down
    drop_table :roles
  end
end
