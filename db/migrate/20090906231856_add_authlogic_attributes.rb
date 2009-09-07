class AddAuthlogicAttributes < ActiveRecord::Migration
  def self.up
    change_column :users, :login, :string, :null => false
    change_column :users, :email, :string, :null => false
    change_column :users, :crypted_password, :string, :null => false
    change_column :users, :salt, :string, :null => false
    add_column :users, :persistence_token, :string, :null => false
    add_column :users, :perishable_token, :string, :null => false
    add_column :users, :login_count, :integer, :null => false, :default => 0
    add_column :users, :failed_login_count, :integer, :null => false, :default => 0
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
  end

  def self.down
    change_column :users, :login, :string, :null => true
    change_column :users, :email, :string, :null => true
    change_column :users, :crypted_password, :string, :null => true
    change_column :users, :salt, :string, :null => true
    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :login_count
    remove_column :users, :failed_login_count
    remove_column :users, :last_request_at
    remove_column :users, :current_login_at
    remove_column :users, :last_login_at
    remove_column :users, :current_login_ip
    remove_column :users, :last_login_ip
  end
end
