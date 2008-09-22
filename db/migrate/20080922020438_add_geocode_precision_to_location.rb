class AddGeocodePrecisionToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :geocode_precision, :string
  end

  def self.down
    remove_column :locations, :geocode_precision
  end
end
