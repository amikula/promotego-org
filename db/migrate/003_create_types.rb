class CreateTypes < ActiveRecord::Migration
  def self.up
    create_table :types do |t|
      t.string :name

      t.timestamps
    end

    ["Go Club", "Coffee House", "Park", "Pub", "Other"].each do |type|
      Type.create(:name => type)
    end
  end

  def self.down
    drop_table :types
  end
end
