class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name
      t.integer :type_id
      t.integer :user_id
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :hours
      t.float :lat
      t.float :lng
      t.string :url
      t.string :description
      t.text :contacts

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
