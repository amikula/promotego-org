class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.float :lat
      t.float :lng
      t.string :geocode_precision
      t.boolean :public
      t.boolean :hidden
      t.string :addressable_type
      t.integer :addressable_id

      t.timestamps
    end

    add_index :addresses, [:addressable_id, :addressable_type]
  end

  def self.down
    drop_table :addresses
  end
end
