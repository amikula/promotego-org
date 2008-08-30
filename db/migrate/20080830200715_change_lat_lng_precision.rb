class ChangeLatLngPrecision < ActiveRecord::Migration
  def self.up
    change_column :locations, :lat, :decimal, :precision => 15, :scale => 10
    change_column :locations, :lng, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    change_column :locations, :lat, :float
    change_column :locations, :lng, :float
  end
end
