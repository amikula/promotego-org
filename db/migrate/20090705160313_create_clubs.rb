class CreateClubs < ActiveRecord::Migration
  def self.up
    create_table :clubs do |t|
      t.string :contacts
      t.string :description
      t.string :foreign_key
      t.boolean :hidden
      t.string :hours
      t.string :name
      t.string :slug
      t.string :source_id
      t.string :url
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :clubs
  end
end
