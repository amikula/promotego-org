class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name
      t.integer :type_id
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :phone_number
      t.string :hours
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
