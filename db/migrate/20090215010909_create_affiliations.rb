class CreateAffiliations < ActiveRecord::Migration
  def self.up
    create_table :affiliations do |t|
      t.integer :location_id
      t.integer :affiliate_id
      t.date :expires

      t.timestamps
    end
  end

  def self.down
    drop_table :affiliations
  end
end
