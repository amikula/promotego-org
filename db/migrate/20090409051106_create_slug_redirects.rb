class CreateSlugRedirects < ActiveRecord::Migration
  def self.up
    create_table :slug_redirects do |t|
      t.string :slug
      t.integer :location_id

      t.timestamps
    end
  end

  def self.down
    drop_table :slug_redirects
  end
end
