class CreateAffiliates < ActiveRecord::Migration
  def self.up
    create_table :affiliates do |t|
      t.string :name
      t.string :full_name
      t.string :logo_path
      t.integer :admin_role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :affiliates
  end
end
